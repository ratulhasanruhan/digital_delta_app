import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/ui_tokens.dart';
import '../../widgets/dd_page_intro.dart';
import '../identity/services/identity_service.dart';
import 'relay_service.dart';

/// M3 — store-and-forward + E2E sealed payload demo.
class RelayHubPage extends StatelessWidget {
  const RelayHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final relay = context.watch<MeshRelayService>();
    final id = context.watch<IdentityService>();

    return ListView(
      padding: UiTokens.pageInsets.copyWith(bottom: 28),
      children: [
        DdPageIntro(
          title: 'Encrypted relay',
          description:
              'Messages are sealed for the recipient only. Volunteers can forward them without reading the contents.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () async {
            try {
              final pk = await id.publicKeyBytes;
              await relay.enqueueSealed(
                recipientPublicKeyBytes: pk,
                plaintextUtf8:
                    'HELLO|${DateTime.now().toIso8601String()}|delta-sync',
              );
              relay.logRoleSwitch('relay');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enqueued sealed frame')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e')),
                );
              }
            }
          },
          icon: const Icon(Icons.send),
          label: const Text('Send sealed message (loopback test)'),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () async {
            final pk = await id.publicKeyBytes;
            final fp = MeshRelayService.fingerprintPublicKey(pk);
            final m = relay.peekForDest(fp);
            if (m == null) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No pending message for this device')),
                );
              }
              return;
            }
            try {
              final clear = await relay.decryptForRecipient(
                recipientPublicKeyBytes: pk,
                sealedPayloadJson: m.sealedPayloadJson,
              );
              await relay.acknowledgeDelivered(m.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Decrypted: $clear')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Decrypt failed: $e')),
                );
              }
            }
          },
          child: const Text('Decrypt & ACK head-of-line'),
        ),
        const SizedBox(height: 8),
        Text(
          'Queue (${relay.pending.length})',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        for (final m in relay.pending)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text('id ${m.id.substring(0, 8)}…', style: Theme.of(context).textTheme.titleSmall),
              subtitle: Text('dest fp ${m.destFingerprint.substring(0, 12)}… • TTL ${m.ttlSeconds}s'),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Relay role log',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        for (final e in relay.roleHistory.take(8))
          ListTile(
            dense: true,
            title: Text(e.value),
            subtitle: Text(e.key),
          ),
      ],
    );
  }
}
