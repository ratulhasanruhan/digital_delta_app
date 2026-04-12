import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart' as c;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/supply_repository.dart';

/// M3.1 / M3.3 — store-and-forward with TTL + dedup; AES-256-GCM with key = SHA-256(recipientPubKey)[:32].
/// Relay/storage only sees opaque `{nonce, ct, mac}` — wrong key fails MAC at decrypt (see `test/relay_encryption_test.dart`).
class RelayMessage {
  RelayMessage({
    required this.id,
    required this.destFingerprint,
    required this.createdAt,
    required this.ttlSeconds,
    required this.sealedPayloadJson,
    required this.hopCount,
  });

  final String id;
  final String destFingerprint;
  final DateTime createdAt;
  final int ttlSeconds;
  /// Opaque to relays: AES-GCM fields as JSON (nonce, ciphertext, mac).
  final String sealedPayloadJson;
  final int hopCount;

  bool get isExpired =>
      DateTime.now().difference(createdAt).inSeconds > ttlSeconds;
}

/// Store-and-forward with optional SQLite persistence (`relay_outbox`).
class MeshRelayService extends ChangeNotifier {
  MeshRelayService({SupplyRepository? repository}) : _repo = repository;

  final SupplyRepository? _repo;
  final Uuid _uuid = const Uuid();
  final Queue<RelayMessage> _queue = Queue<RelayMessage>();
  final Set<String> _seenIds = {};
  final Map<String, String> _roleSwitchLog = {};

  List<RelayMessage> get pending => _queue.where((m) => !m.isExpired).toList();

  /// Reload queue from disk (call after [SupplyRepository.init]).
  Future<void> hydrateFromDisk() async {
    final db = _repo;
    if (db == null) return;
    try {
      final rows = await db.relayPendingRows();
      _queue.clear();
      _seenIds.clear();
      for (final r in rows) {
        final id = r['id']! as String;
        final createdAt = DateTime.fromMillisecondsSinceEpoch(r['created_at']! as int);
        final msg = RelayMessage(
          id: id,
          destFingerprint: r['dest_fingerprint']! as String,
          createdAt: createdAt,
          ttlSeconds: r['ttl_seconds']! as int,
          sealedPayloadJson: r['sealed_payload']! as String,
          hopCount: r['hop_count']! as int,
        );
        _seenIds.add(id);
        _queue.addLast(msg);
      }
      notifyListeners();
    } catch (e, st) {
      debugPrint('relay hydrate: $e\n$st');
    }
  }

  static String fingerprintPublicKey(List<int> publicKeyBytes) =>
      c.sha256.convert(publicKeyBytes).toString();

  Future<RelayMessage> enqueueSealed({
    required List<int> recipientPublicKeyBytes,
    required String plaintextUtf8,
    int ttlSeconds = 3600,
  }) async {
    final destFp = fingerprintPublicKey(recipientPublicKeyBytes);
    final keyBytes = c.sha256.convert(recipientPublicKeyBytes).bytes;
    final aes = AesGcm.with256bits();
    final key = SecretKey(keyBytes.sublist(0, 32));
    final box = await aes.encrypt(
      utf8.encode(plaintextUtf8),
      secretKey: key,
    );
    final sealed = jsonEncode({
      'nonce': base64Encode(box.nonce),
      'ct': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
    final id = _uuid.v4();
    _seenIds.add(id);
    final msg = RelayMessage(
      id: id,
      destFingerprint: destFp,
      createdAt: DateTime.now(),
      ttlSeconds: ttlSeconds,
      sealedPayloadJson: sealed,
      hopCount: 0,
    );
    _queue.addLast(msg);
    final store = _repo;
    if (store != null) {
      try {
        await store.relayInsertRow(
          id: id,
          destFingerprint: destFp,
          sealedPayload: sealed,
          ttlSeconds: ttlSeconds,
          hopCount: 0,
        );
      } catch (e, st) {
        debugPrint('relay persist: $e\n$st');
      }
    }
    notifyListeners();
    return msg;
  }

  /// Recipient-only decrypt (same device demo uses identity public key bytes).
  Future<String> decryptForRecipient({
    required List<int> recipientPublicKeyBytes,
    required String sealedPayloadJson,
  }) async {
    final keyBytes = c.sha256.convert(recipientPublicKeyBytes).bytes;
    final aes = AesGcm.with256bits();
    final key = SecretKey(keyBytes.sublist(0, 32));
    final m = jsonDecode(sealedPayloadJson) as Map<String, dynamic>;
    final box = SecretBox(
      base64Decode(m['ct']! as String),
      nonce: base64Decode(m['nonce']! as String),
      mac: Mac(base64Decode(m['mac']! as String)),
    );
    final clear = await aes.decrypt(box, secretKey: key);
    return utf8.decode(clear);
  }

  RelayMessage? peekForDest(String destFingerprintSha256Hex) {
    for (final m in _queue) {
      if (!m.isExpired && m.destFingerprint == destFingerprintSha256Hex) {
        return m;
      }
    }
    return null;
  }

  Future<void> acknowledgeDelivered(String id) async {
    _queue.removeWhere((x) => x.id == id);
    _seenIds.remove(id);
    final store = _repo;
    if (store != null) {
      try {
        await store.relayDelete(id);
      } catch (e, st) {
        debugPrint('relay delete: $e\n$st');
      }
    }
    notifyListeners();
  }

  /// M3.2 — log automatic role switch (client ↔ relay).
  void logRoleSwitch(String role) {
    _roleSwitchLog[DateTime.now().toIso8601String()] = role;
    notifyListeners();
  }

  Iterable<MapEntry<String, String>> get roleHistory => _roleSwitchLog.entries;
}
