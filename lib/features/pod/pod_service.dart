import 'dart:convert';

import 'package:crypto/crypto.dart' as c;
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/supply_repository.dart';
import '../identity/services/identity_service.dart';

/// M5 — signed PoD challenge + single-use nonces (replay protection).
class PodChallenge {
  PodChallenge({
    required this.deliveryId,
    required this.senderPubKeyHex,
    required this.payloadHashHex,
    required this.nonce,
    required this.timestampMs,
    required this.signatureHex,
  });

  final String deliveryId;
  final String senderPubKeyHex;
  final String payloadHashHex;
  final String nonce;
  final int timestampMs;
  final String signatureHex;

  String get canonical =>
      '$deliveryId|$senderPubKeyHex|$payloadHashHex|$nonce|$timestampMs';

  Map<String, dynamic> toJson() => {
        'delivery_id': deliveryId,
        'sender_pubkey_hex': senderPubKeyHex,
        'payload_hash_hex': payloadHashHex,
        'nonce': nonce,
        'timestamp_ms': timestampMs,
        'signature_hex': signatureHex,
      };

  static PodChallenge? tryParse(String rawJson) {
    try {
      final m = jsonDecode(rawJson) as Map<String, dynamic>;
      return PodChallenge(
        deliveryId: m['delivery_id']! as String,
        senderPubKeyHex: m['sender_pubkey_hex']! as String,
        payloadHashHex: m['payload_hash_hex']! as String,
        nonce: m['nonce']! as String,
        timestampMs: m['timestamp_ms']! as int,
        signatureHex: m['signature_hex']! as String,
      );
    } catch (_) {
      return null;
    }
  }
}

class PodService {
  PodService(this._identity, this._repository);

  final IdentityService _identity;
  final SupplyRepository _repository;
  static const _kNonces = 'pod_used_nonces_v1';

  Future<PodChallenge> buildChallenge({
    required String deliveryId,
    required String payloadUtf8,
  }) async {
    await _identity.init();
    final nonce = _randomNonce();
    final payloadHash = c.sha256.convert(utf8.encode(payloadUtf8)).toString();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final pub = _identity.publicKeyHex ?? '';
    final canonical = '$deliveryId|$pub|$payloadHash|$nonce|$ts';
    final sig = await _identity.signUtf8(canonical);
    final sigHex = sig.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return PodChallenge(
      deliveryId: deliveryId,
      senderPubKeyHex: pub,
      payloadHashHex: payloadHash,
      nonce: nonce,
      timestampMs: ts,
      signatureHex: sigHex,
    );
  }

  /// M5.1 — recipient countersignature over acknowledgement binding.
  Future<String> recipientCountersign(PodChallenge ch) async {
    await _identity.init();
    final pub = _identity.publicKeyHex ?? '';
    final msg = 'POD_ACK|${ch.deliveryId}|${ch.nonce}|$pub';
    final sig = await _identity.signUtf8(msg);
    return sig.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Verify driver QR, consume nonce, countersign, append M5.3 CRDT receipt.
  Future<String?> finalizeDelivery({
    required PodChallenge ch,
    required String cargoPayloadUtf8,
  }) async {
    final hashCheck = c.sha256.convert(utf8.encode(cargoPayloadUtf8)).toString();
    if (hashCheck != ch.payloadHashHex) {
      return 'ERR_PAYLOAD_HASH_MISMATCH';
    }
    final err = await verifyWithPrefs(ch);
    if (err != null) {
      return err;
    }
    final recipSig = await recipientCountersign(ch);
    await _repository.appendPodReceiptLedger(
      deliveryId: ch.deliveryId,
      driverSignatureHex: ch.signatureHex,
      recipientSignatureHex: recipSig,
      payloadHashHex: ch.payloadHashHex,
    );
    return null;
  }

  Future<String?> verifyAndConsume(
    PodChallenge ch, {
    required Future<void> Function(List<String> used) persistNonces,
    required Future<List<String>> Function() loadNonces,
  }) async {
    final used = await loadNonces();
    if (used.contains(ch.nonce)) {
      return 'ERR_REPLAY_NONCE';
    }
    final pubBytes = _hexToBytes(ch.senderPubKeyHex);
    final sigBytes = _hexToBytes(ch.signatureHex);
    final publicKey = SimplePublicKey(
      pubBytes,
      type: KeyPairType.ed25519,
    );
    final algorithm = Ed25519();
    final ok = await algorithm.verify(
      utf8.encode(ch.canonical),
      signature: Signature(sigBytes, publicKey: publicKey),
    );
    if (!ok) {
      return 'ERR_BAD_SIGNATURE';
    }
    used.add(ch.nonce);
    await persistNonces(used.take(500).toList());
    return null;
  }

  Future<String?> verifyWithPrefs(PodChallenge ch) async {
    final prefs = await SharedPreferences.getInstance();
    return verifyAndConsume(
      ch,
      loadNonces: () async => prefs.getStringList(_kNonces) ?? [],
      persistNonces: (u) async => prefs.setStringList(_kNonces, u),
    );
  }

  String _randomNonce() {
    final b = List<int>.generate(
      32,
      (i) => (DateTime.now().microsecondsSinceEpoch + i) % 256,
    );
    return c.sha256.convert(b).toString().substring(0, 24);
  }

  static List<int> _hexToBytes(String hex) {
    final out = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      out.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return out;
  }
}
