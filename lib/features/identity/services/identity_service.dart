import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:otp/otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/rbac.dart';
import '../../../data/supply_repository.dart';
import 'audit_log_service.dart';

const _kTotpSecret = 'totp_secret_base32';
const _kEd25519Seed = 'ed25519_seed_b64';
const _kRole = 'user_role';
const _kHotpCounter = 'hotp_counter';
const _kPubkeyLedgerSynced = 'pubkey_ledger_logged_hex';

/// M1.1–M1.2 — offline TOTP + Ed25519 keypair in secure storage.
class IdentityService extends ChangeNotifier {
  IdentityService({
    AuditLogService? auditLog,
    FlutterSecureStorage? secure,
    SupplyRepository? repository,
  })  : _repo = repository,
        _audit = auditLog ?? AuditLogService(),
        _secure = secure ?? const FlutterSecureStorage();

  final AuditLogService _audit;
  final FlutterSecureStorage _secure;
  final SupplyRepository? _repo;

  final Ed25519 _ed25519 = Ed25519();

  UserRole _role = UserRole.fieldVolunteer;
  String? _publicKeyHex;
  String? _totpSecret;
  bool _ready = false;
  int _hotpCounter = 0;

  UserRole get role => _role;
  String? get publicKeyHex => _publicKeyHex;
  bool get isReady => _ready;
  int get hotpCounter => _hotpCounter;

  /// Raw Ed25519 public key bytes (for E2E relay demos).
  Future<List<int>> get publicKeyBytes async {
    final seedB64 = await _secure.read(key: _kEd25519Seed);
    if (seedB64 == null) throw StateError('missing seed');
    final kp = await _ed25519.newKeyPairFromSeed(base64Url.decode(seedB64));
    final pub = await kp.extractPublicKey();
    return pub.bytes;
  }

  Future<void> init() async {
    try {
      OTP.useTOTPPaddingForHOTP = true;
      await _audit.init();
      final prefs = await SharedPreferences.getInstance();
      _role = userRoleFromStorage(prefs.getString(_kRole));
      _hotpCounter = prefs.getInt(_kHotpCounter) ?? 0;

      var seedB64 = await _secure.read(key: _kEd25519Seed);
      if (seedB64 == null || seedB64.isEmpty) {
        final seed = _randomBytes(32);
        seedB64 = base64UrlEncode(seed);
        await _secure.write(key: _kEd25519Seed, value: seedB64);
        await _audit.append(
          event: 'keypair_provisioned',
          payload: {'algo': 'ed25519', 'note': 'new seed generated'},
        );
      }

      final seed = base64Url.decode(seedB64);
      final kp = await _ed25519.newKeyPairFromSeed(seed);
      final pub = await kp.extractPublicKey();
      _publicKeyHex = _bytesToHex(pub.bytes);

      _totpSecret = await _secure.read(key: _kTotpSecret);
      if (_totpSecret == null || _totpSecret!.isEmpty) {
        _totpSecret = _newBase32Secret(20);
        await _secure.write(key: _kTotpSecret, value: _totpSecret!);
        await _audit.append(
          event: 'totp_secret_provisioned',
          payload: {'length': _totpSecret!.length},
        );
      }

      await _syncPubkeyLedgerRow(prefs);

      _ready = true;
      notifyListeners();
    } catch (e, st) {
      debugPrint('IdentityService.init failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> _syncPubkeyLedgerRow(SharedPreferences prefs) async {
    final keyHex = _publicKeyHex;
    final repo = _repo;
    if (keyHex == null || repo == null) {
      return;
    }
    try {
      final logged = prefs.getString(_kPubkeyLedgerSynced);
      if (logged == keyHex) {
        return;
      }
      await repo.appendPublicKeyLedger(
        replicaId: repo.replicaId,
        pubkeyHex: keyHex,
        event: 'provisioned',
      );
      await prefs.setString(_kPubkeyLedgerSynced, keyHex);
    } catch (e, st) {
      debugPrint('IdentityService._syncPubkeyLedgerRow: $e\n$st');
    }
  }

  Future<void> setRole(UserRole next) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRole, next.name);
    _role = next;
    await _audit.append(
      event: 'role_changed',
      payload: {'role': next.name},
    );
    notifyListeners();
  }

  /// RFC 6238-style TOTP (SHA-256) — works fully offline.
  String currentTotp({DateTime? now}) {
    final secret = _totpSecret;
    if (secret == null) throw StateError('not initialized');
    final t = now ?? DateTime.now();
    return OTP.generateTOTPCodeString(
      secret,
      t.millisecondsSinceEpoch,
      algorithm: Algorithm.SHA256,
    );
  }

  /// Verifies a 6-digit TOTP the user typed (±2 intervals for clock skew).
  bool verifyTotpInput(String raw) {
    final secret = _totpSecret;
    if (secret == null) return false;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 6) return false;
    final ms = DateTime.now().millisecondsSinceEpoch;
    const stepMs = 30000;
    final center = (ms ~/ stepMs) * stepMs;
    for (var w = -2; w <= 2; w++) {
      final t = center + w * stepMs;
      final code = OTP.generateTOTPCodeString(
        secret,
        t,
        algorithm: Algorithm.SHA256,
      );
      if (digits == code) return true;
    }
    return false;
  }

  /// RFC 4226 HOTP (SHA-256 + TOTP-style secret padding via [OTP.useTOTPPaddingForHOTP]).
  String currentHotp() {
    final secret = _totpSecret;
    if (secret == null) throw StateError('not initialized');
    return OTP.generateHOTPCodeString(
      secret,
      _hotpCounter,
      algorithm: Algorithm.SHA256,
    );
  }

  Future<void> advanceHotpCounter() async {
    try {
      _hotpCounter++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kHotpCounter, _hotpCounter);
      await _audit.append(
        event: 'hotp_counter_advanced',
        payload: {'counter': _hotpCounter},
      );
      notifyListeners();
    } catch (e, st) {
      debugPrint('advanceHotpCounter failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> rotateSigningKeys() async {
    if (!_role.can(Permission.manageIdentity)) {
      throw StateError('manageIdentity permission required');
    }
    try {
      final seed = _randomBytes(32);
      final seedB64 = base64UrlEncode(seed);
      await _secure.write(key: _kEd25519Seed, value: seedB64);
      final kp = await _ed25519.newKeyPairFromSeed(seed);
      final pub = await kp.extractPublicKey();
      _publicKeyHex = _bytesToHex(pub.bytes);
      await _audit.append(
        event: 'signing_keys_rotated',
        payload: {'algo': 'ed25519'},
      );
      final prefs = await SharedPreferences.getInstance();
      final repo = _repo;
      if (repo != null && _publicKeyHex != null) {
        await repo.appendPublicKeyLedger(
          replicaId: repo.replicaId,
          pubkeyHex: _publicKeyHex!,
          event: 'rotated',
        );
        await prefs.setString(_kPubkeyLedgerSynced, _publicKeyHex!);
      }
      notifyListeners();
    } catch (e, st) {
      debugPrint('rotateSigningKeys failed: $e\n$st');
      rethrow;
    }
  }

  int totpSecondsRemaining({DateTime? now}) {
    final t = now ?? DateTime.now();
    const interval = 30;
    final epoch = t.millisecondsSinceEpoch ~/ 1000;
    return interval - (epoch % interval);
  }

  Future<Signature> signUtf8(String message) async {
    final seedB64 = await _secure.read(key: _kEd25519Seed);
    if (seedB64 == null) throw StateError('missing seed');
    final kp = await _ed25519.newKeyPairFromSeed(base64Url.decode(seedB64));
    final bytes = utf8.encode(message);
    return _ed25519.sign(bytes, keyPair: kp);
  }

  Future<void> logOtpFailure() async {
    await _audit.append(
      event: 'otp_failure',
      payload: {'reason': 'mismatch_or_expired'},
    );
  }

  Future<void> logLoginSuccess() async {
    await _audit.append(
      event: 'login_success',
      payload: {'role': _role.name},
    );
  }

  AuditLogService get audit => _audit;

  static List<int> _randomBytes(int n) {
    final r = Random.secure();
    return List<int>.generate(n, (_) => r.nextInt(256));
  }

  /// RFC 4648 base32 alphabet without padding — compatible with `otp` package.
  static String _newBase32Secret(int numBytes) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final raw = _randomBytes(numBytes);
    final buffer = StringBuffer();
    var bitBuffer = 0;
    var bitsLeft = 0;
    for (final b in raw) {
      bitBuffer = (bitBuffer << 8) | b;
      bitsLeft += 8;
      while (bitsLeft >= 5) {
        bitsLeft -= 5;
        final idx = (bitBuffer >> bitsLeft) & 31;
        buffer.write(alphabet[idx]);
      }
    }
    if (bitsLeft > 0) {
      buffer.write(alphabet[(bitBuffer << (5 - bitsLeft)) & 31]);
    }
    return buffer.toString();
  }

  static String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
