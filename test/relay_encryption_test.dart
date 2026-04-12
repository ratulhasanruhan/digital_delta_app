import 'package:digital_delta_app/features/mesh/relay_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('M3.3 — sealed relay blob fails to decrypt with wrong recipient key', () async {
    final relay = MeshRelayService();
    final alice = List<int>.generate(32, (i) => i + 1);
    final bob = List<int>.generate(32, (i) => i + 50);
    final msg = await relay.enqueueSealed(
      recipientPublicKeyBytes: alice,
      plaintextUtf8: 'relief manifest',
    );
    expect(
      () => relay.decryptForRecipient(
        recipientPublicKeyBytes: bob,
        sealedPayloadJson: msg.sealedPayloadJson,
      ),
      throwsA(anything),
    );
  });
}
