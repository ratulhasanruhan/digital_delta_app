import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:battery_plus/battery_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../data/supply_repository.dart';

/// Bluetooth SIG–style company id for manufacturer data (0xDD, 0x01 LE → 0x01DD).
const kDigitalDeltaManufacturerId = 0x01dd;

/// BLE proximity layer: short binary frames only (no JSON on air). Bulk sync stays on Wi‑Fi gRPC.
class BleMeshPeer {
  BleMeshPeer({
    required this.deviceId,
    required this.fingerprintHex,
    this.rssi,
    this.advName,
  });

  final String deviceId;
  final String fingerprintHex;
  final int? rssi;
  final String? advName;
}

/// M8.4 — beacon duty cycle derived from battery, motion, and peer proximity (contest rubric).
///
/// Policy (multiplicative, clamped to [0.05, 1.0]):
/// - Battery &lt; 30%: effective broadcast frequency × 0.4 (i.e. −60% frequency).
/// - Stationary (low user-acceleration magnitude): × 0.2 (−80% frequency vs moving).
/// - At least one BLE peer visible: × 0.8 (slightly lower duty when mesh neighbors present).
class BleMeshController extends ChangeNotifier {
  BleMeshController({required this.repository});

  final SupplyRepository repository;
  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();
  final Battery _battery = Battery();

  bool _advertising = false;
  bool _scanning = false;
  String? _error;
  final Map<String, BleMeshPeer> _peers = {};

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<UserAccelerometerEvent>? _accelSub;
  Timer? _dutyTimer;

  /// Session wants beacon when app calls [startAdvertising] (e.g. resumed).
  bool _sessionWantsBeacon = false;

  int? _batteryPct;
  bool _stationary = true;
  double _lastAccelMag = 0;
  double _cachedDuty = 1;

  StreamSubscription<BatteryState>? _batterySub;

  bool get isAdvertising => _advertising;

  /// True after [startAdvertising] until [stopAdvertising] — M8.4 may toggle hardware ads on/off.
  bool get isBeaconSessionActive => _sessionWantsBeacon;

  bool get isScanning => _scanning;
  String? get lastError => _error;
  int? get batteryPercent => _batteryPct;
  bool get stationary => _stationary;

  /// Current target duty cycle 0–1 (higher = more “on” time in each window).
  double get beaconDutyCycle => _cachedDuty;

  String get throttleSummary {
    final b = _batteryPct;
    final bat = b != null && b < 30 ? 'battery<30% ' : '';
    final st = _stationary ? 'stationary ' : '';
    final pr = _peers.isNotEmpty ? 'peers=${_peers.length} ' : '';
    return 'duty=${_cachedDuty.toStringAsFixed(2)} $bat$st$pr(M8.4)';
  }

  List<BleMeshPeer> get peers {
    final list = _peers.values.toList(growable: false);
    list.sort((a, b) => (b.rssi ?? -1000).compareTo(a.rssi ?? -1000));
    return list;
  }

  Uint8List replicaFingerprint() {
    final digest = sha256.convert(utf8.encode(repository.replicaId));
    return Uint8List.fromList(digest.bytes.sublist(0, 16));
  }

  static String fingerprintHexFromBytes(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  String _fingerprintUuidString(Uint8List fp) {
    final h = fingerprintHexFromBytes(fp);
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20, 32)}';
  }

  Future<bool> ensurePermissions() async {
    try {
      if (Platform.isAndroid) {
        var scan = await Permission.bluetoothScan.request();
        var connect = await Permission.bluetoothConnect.request();
        if (!scan.isGranted) {
          scan = await Permission.bluetooth.request();
        }
        if (!connect.isGranted) {
          connect = await Permission.bluetooth.request();
        }
        return scan.isGranted && connect.isGranted;
      }
      return true;
    } catch (e) {
      _error = '$e';
      notifyListeners();
      return false;
    }
  }

  Future<void> _refreshDutyInputs() async {
    try {
      _batteryPct = await _battery.batteryLevel;
    } catch (_) {}
    _cachedDuty = _computeDutyCycle();
    notifyListeners();
  }

  /// M8.4 — rubric-aligned multiplicative policy.
  double _computeDutyCycle() {
    var d = 1.0;
    final b = _batteryPct;
    if (b != null && b < 30) {
      d *= 0.4;
    }
    if (_stationary) {
      d *= 0.2;
    }
    if (_peers.isNotEmpty) {
      d *= 0.8;
    }
    return d.clamp(0.05, 1.0);
  }

  void _startSensorHooks() {
    _accelSub ??= userAccelerometerEventStream().listen((e) {
      _lastAccelMag = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      _stationary = _lastAccelMag < 0.45;
    });
    _batterySub ??= _battery.onBatteryStateChanged.listen((_) {
      unawaited(_refreshDutyInputs());
    });
  }

  void _stopSensorHooks() {
    unawaited(_accelSub?.cancel());
    _accelSub = null;
    unawaited(_batterySub?.cancel());
    _batterySub = null;
  }

  /// 60s sliding window: beacon is ON for the first [duty]*60s of each minute (stable pattern).
  Future<void> _syncBeaconToDutyWindow() async {
    if (!_sessionWantsBeacon) {
      return;
    }
    await _refreshDutyInputs();
    final duty = _cachedDuty;
    const periodMs = 60000;
    final t = DateTime.now().millisecondsSinceEpoch % periodMs;
    final wantOn = t < (periodMs * duty);
    if (wantOn && !_advertising) {
      await _startAdvertisingRaw();
    } else if (!wantOn && _advertising) {
      await _stopAdvertisingRaw();
    }
  }

  Future<void> _startAdvertisingRaw() async {
    if (_advertising) {
      return;
    }
    final ok = await ensurePermissions();
    if (!ok) {
      return;
    }
    try {
      final supported = await _peripheral.isSupported;
      if (!supported) {
        _error = 'BLE peripheral not supported';
        notifyListeners();
        return;
      }
      final fp = replicaFingerprint();
      if (Platform.isAndroid) {
        await _peripheral.start(
          advertiseData: AdvertiseData(
            manufacturerId: kDigitalDeltaManufacturerId,
            manufacturerData: fp,
            includeDeviceName: false,
          ),
        );
      } else if (Platform.isIOS) {
        await _peripheral.start(
          advertiseData: AdvertiseData(
            serviceUuid: _fingerprintUuidString(fp),
            localName: 'DD',
            includeDeviceName: true,
          ),
        );
      } else {
        _error = 'BLE beacon not supported on this OS';
        notifyListeners();
        return;
      }
      _advertising = await _peripheral.isAdvertising;
      _error = _advertising ? null : 'Advertising did not start (permissions or Bluetooth off?)';
    } catch (e) {
      _error = '$e';
      _advertising = false;
    }
    notifyListeners();
  }

  Future<void> _stopAdvertisingRaw() async {
    if (!_advertising) {
      return;
    }
    try {
      await _peripheral.stop();
    } catch (_) {}
    _advertising = false;
    notifyListeners();
  }

  /// Starts M8.4 throttled beaconing when the app session wants mesh presence (e.g. resumed).
  Future<void> startAdvertising() async {
    _sessionWantsBeacon = true;
    _startSensorHooks();
    _dutyTimer ??= Timer.periodic(const Duration(milliseconds: 500), (_) {
      unawaited(_syncBeaconToDutyWindow());
    });
    unawaited(_syncBeaconToDutyWindow());
  }

  Future<void> stopAdvertising() async {
    _sessionWantsBeacon = false;
    _dutyTimer?.cancel();
    _dutyTimer = null;
    _stopSensorHooks();
    await _stopAdvertisingRaw();
  }

  Future<void> startScan() async {
    if (_scanning) {
      return;
    }
    final ok = await ensurePermissions();
    if (!ok) {
      return;
    }
    try {
      if (!await FlutterBluePlus.isSupported) {
        _error = 'BLE not supported';
        notifyListeners();
        return;
      }
      await _scanSub?.cancel();
      _peers.clear();
      _scanSub = FlutterBluePlus.scanResults.listen(_onScan);
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 30),
        androidUsesFineLocation: false,
      );
      _scanning = true;
      _error = null;
    } catch (e) {
      _error = '$e';
      _scanning = false;
    }
    notifyListeners();
  }

  void _onScan(List<ScanResult> results) {
    final own = fingerprintHexFromBytes(replicaFingerprint());
    for (final r in results) {
      Uint8List? fp;
      final md = r.advertisementData.manufacturerData[kDigitalDeltaManufacturerId];
      if (md != null && md.length >= 16) {
        fp = Uint8List.fromList(md.take(16).toList());
      } else {
        for (final u in r.advertisementData.serviceUuids) {
          final parsed = _uuidToFingerprint(u.str128);
          if (parsed != null) {
            fp = parsed;
            break;
          }
        }
      }
      if (fp == null) {
        continue;
      }
      final hex = fingerprintHexFromBytes(fp);
      if (hex == own) {
        continue;
      }
      final id = r.device.remoteId.str;
      _peers[id] = BleMeshPeer(
        deviceId: id,
        fingerprintHex: hex,
        rssi: r.rssi,
        advName: r.advertisementData.advName,
      );
    }
    unawaited(_refreshDutyInputs());
    notifyListeners();
  }

  Uint8List? _uuidToFingerprint(String uuid) {
    final clean = uuid.replaceAll('-', '').toLowerCase();
    if (clean.length != 32) {
      return null;
    }
    try {
      final out = Uint8List(16);
      for (var i = 0; i < 16; i++) {
        out[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
      }
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    await _scanSub?.cancel();
    _scanSub = null;
    _scanning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _dutyTimer?.cancel();
    _stopSensorHooks();
    unawaited(stopScan());
    unawaited(stopAdvertising());
    super.dispose();
  }
}
