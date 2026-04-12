import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';

/// M3.2 — client vs relay from battery + (optional) simulated RSSI dBm.
enum MeshNodeMode { client, relay }

/// Heuristic: low battery + very weak “signal” → prefer client (receive only);
/// healthy battery or strong signal → can act as relay.
class MeshNodeRoleEvaluator {
  MeshNodeRoleEvaluator({Battery? battery}) : _battery = battery ?? Battery();

  final Battery _battery;

  /// [simulatedRssiDbm] defaults to a moderate indoor Wi‑Fi–like value for demos.
  Future<MeshNodeMode> evaluate({double? simulatedRssiDbm}) async {
    try {
      final level = await _battery.batteryLevel;
      final rssi = simulatedRssiDbm ?? -72.0;
      if (level < 30 && rssi < -88) {
        return MeshNodeMode.client;
      }
      if (level >= 45 || rssi > -78) {
        return MeshNodeMode.relay;
      }
      return MeshNodeMode.client;
    } catch (e, st) {
      debugPrint('MeshNodeRoleEvaluator: $e\n$st');
      return MeshNodeMode.relay;
    }
  }
}
