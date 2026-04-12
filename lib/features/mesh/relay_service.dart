import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' as c;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/supply_repository.dart';

/// Where the frame sits in the A → B → C story (single-device simulation).
enum RelayHolder { origin, relay, recipient }

RelayHolder relayHolderFromStatus(String s) {
  switch (s) {
    case 'at_relay':
      return RelayHolder.relay;
    case 'at_recipient':
      return RelayHolder.recipient;
    case 'pending':
    default:
      return RelayHolder.origin;
  }
}

String statusFromHolder(RelayHolder h) {
  switch (h) {
    case RelayHolder.origin:
      return 'pending';
    case RelayHolder.relay:
      return 'at_relay';
    case RelayHolder.recipient:
      return 'at_recipient';
  }
}

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
    required this.holder,
  });

  final String id;
  final String destFingerprint;
  final DateTime createdAt;
  final int ttlSeconds;
  /// Opaque to relays: AES-GCM fields as JSON (nonce, ciphertext, mac).
  final String sealedPayloadJson;
  final int hopCount;
  final RelayHolder holder;

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
  /// M3.1 — duplicate frame id seen at relay hop (second copy dropped).
  final Set<String> _relaySeenIds = {};
  final Map<String, String> _roleSwitchLog = {};

  bool _relayPaused = false;

  bool get relayPaused => _relayPaused;

  List<RelayMessage> get pending => _queue.where((m) => !m.isExpired).toList();

  RelayMessage? get firstAtOrigin {
    for (final m in pending) {
      if (m.holder == RelayHolder.origin) return m;
    }
    return null;
  }

  RelayMessage? get firstAtRelay {
    for (final m in pending) {
      if (m.holder == RelayHolder.relay) return m;
    }
    return null;
  }

  RelayMessage? _messageById(String id) {
    for (final m in _queue) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// Reload queue from disk (call after [SupplyRepository.init]).
  Future<void> hydrateFromDisk() async {
    final db = _repo;
    if (db == null) return;
    try {
      final rows = await db.relayPendingRows();
      _queue.clear();
      _seenIds.clear();
      _relaySeenIds.clear();
      for (final r in rows) {
        final id = r['id']! as String;
        final createdAt = DateTime.fromMillisecondsSinceEpoch(r['created_at']! as int);
        final status = r['status']! as String;
        final msg = RelayMessage(
          id: id,
          destFingerprint: r['dest_fingerprint']! as String,
          createdAt: createdAt,
          ttlSeconds: r['ttl_seconds']! as int,
          sealedPayloadJson: r['sealed_payload']! as String,
          hopCount: r['hop_count']! as int,
          holder: relayHolderFromStatus(status),
        );
        _seenIds.add(id);
        if (msg.holder == RelayHolder.relay || msg.holder == RelayHolder.recipient) {
          _relaySeenIds.add(id);
        }
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
      holder: RelayHolder.origin,
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

  /// M3.1 — relay B rejects a second delivery with the same [messageId].
  bool claimRelayDeliveryId(String messageId) {
    if (_relaySeenIds.contains(messageId)) {
      return false;
    }
    _relaySeenIds.add(messageId);
    return true;
  }

  void setRelayPaused(bool v) {
    _relayPaused = v;
    logRoleSwitch(v ? 'relay_paused' : 'relay_resumed');
    notifyListeners();
  }

  /// Device A → relay B (opaque forward; hop++).
  Future<void> advanceOriginToRelay(String id) async {
    final m = _messageById(id);
    if (m == null) return;
    if (m.holder != RelayHolder.origin) return;
    if (!claimRelayDeliveryId(id)) {
      debugPrint('M3.1 dedup: duplicate at relay for $id');
      return;
    }
    final nextHop = m.hopCount + 1;
    final updated = RelayMessage(
      id: m.id,
      destFingerprint: m.destFingerprint,
      createdAt: m.createdAt,
      ttlSeconds: m.ttlSeconds,
      sealedPayloadJson: m.sealedPayloadJson,
      hopCount: nextHop,
      holder: RelayHolder.relay,
    );
    _replaceMessageById(updated);
    await _persistProgress(updated);
    logRoleSwitch('relay');
    notifyListeners();
  }

  /// Relay B → recipient C when not paused (opaque; hop++).
  Future<void> advanceRelayToRecipient(String id) async {
    if (_relayPaused) return;
    final m = _messageById(id);
    if (m == null) return;
    if (m.holder != RelayHolder.relay) return;
    final nextHop = m.hopCount + 1;
    final updated = RelayMessage(
      id: m.id,
      destFingerprint: m.destFingerprint,
      createdAt: m.createdAt,
      ttlSeconds: m.ttlSeconds,
      sealedPayloadJson: m.sealedPayloadJson,
      hopCount: nextHop,
      holder: RelayHolder.recipient,
    );
    _replaceMessageById(updated);
    await _persistProgress(updated);
    logRoleSwitch('client');
    notifyListeners();
  }

  void _replaceMessageById(RelayMessage updated) {
    final list = _queue.toList();
    final i = list.indexWhere((m) => m.id == updated.id);
    if (i < 0) return;
    list[i] = updated;
    _queue.clear();
    for (final m in list) {
      _queue.addLast(m);
    }
  }

  Future<void> _persistProgress(RelayMessage m) async {
    final store = _repo;
    if (store == null) return;
    try {
      await store.relayUpdateProgress(
        id: m.id,
        status: statusFromHolder(m.holder),
        hopCount: m.hopCount,
      );
    } catch (e, st) {
      debugPrint('relay update: $e\n$st');
    }
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

  /// M3.3 — proves relay cannot decrypt with an unrelated key (MAC fails).
  Future<void> decryptWithWrongKeyForDemo(String sealedPayloadJson) async {
    final aes = AesGcm.with256bits();
    final fake = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    final key = SecretKey(fake);
    final m = jsonDecode(sealedPayloadJson) as Map<String, dynamic>;
    final box = SecretBox(
      base64Decode(m['ct']! as String),
      nonce: base64Decode(m['nonce']! as String),
      mac: Mac(base64Decode(m['mac']! as String)),
    );
    await aes.decrypt(box, secretKey: key);
  }

  /// Only when the frame has reached the final hop (recipient device).
  RelayMessage? peekForDest(String destFingerprintSha256Hex) {
    for (final m in _queue) {
      if (!m.isExpired &&
          m.holder == RelayHolder.recipient &&
          m.destFingerprint == destFingerprintSha256Hex) {
        return m;
      }
    }
    return null;
  }

  Future<void> acknowledgeDelivered(String id) async {
    _queue.removeWhere((x) => x.id == id);
    _seenIds.remove(id);
    _relaySeenIds.remove(id);
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
