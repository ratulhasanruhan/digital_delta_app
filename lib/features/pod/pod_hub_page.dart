import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/ui_tokens.dart';
import '../../widgets/dd_page_intro.dart';
import '../../crdt/supply_models.dart';
import '../../data/supply_repository.dart';
import '../identity/services/identity_service.dart';
import 'pod_service.dart';

/// M5 — signed QR, replay rejection, scanner.
class PodHubPage extends StatefulWidget {
  const PodHubPage({super.key});

  @override
  State<PodHubPage> createState() => _PodHubPageState();
}

class _PodHubPageState extends State<PodHubPage> {
  final _deliveryId = TextEditingController();
  final _payload = TextEditingController(text: 'crate:water-500L|qty:12');
  PodChallenge? _last;
  String? _scanResult;

  @override
  void dispose() {
    _deliveryId.dispose();
    _payload.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pod = context.watch<PodService>();
    final id = context.watch<IdentityService>();
    final repo = context.watch<SupplyRepository>();

    return ListView(
      padding: UiTokens.pageInsets.copyWith(bottom: 28),
      children: [
        DdPageIntro(
          title: 'Proof of delivery',
          description:
              'The driver shows a signed QR. The recipient scans to verify. Each code is one-time use.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _deliveryId,
          decoration: const InputDecoration(
            labelText: 'Delivery ID',
            hintText: 'e.g. DEL-10042',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _payload,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Cargo payload (hashed + signed)'),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () async {
            final did = _deliveryId.text.trim();
            if (did.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a delivery ID')),
              );
              return;
            }
            try {
              final ch = await pod.buildChallenge(
                deliveryId: did,
                payloadUtf8: _payload.text,
              );
              setState(() => _last = ch);
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          icon: const Icon(Icons.qr_code_2),
          label: const Text('Generate signed QR'),
        ),
        const SizedBox(height: 24),
        if (_last != null) ...[
          Center(
            child: QrImageView(
              data: jsonEncode(_last!.toJson()),
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(jsonEncode(_last!.toJson())),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () async {
              final err = await pod.finalizeDelivery(
                ch: _last!,
                cargoPayloadUtf8: _payload.text,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    err == null
                        ? 'M5.1–M5.3: verified, countersigned, CRDT receipt appended'
                        : 'Rejected: $err',
                  ),
                ),
              );
            },
            child: const Text('Recipient: verify + countersign + ledger'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              final err = await pod.finalizeDelivery(
                ch: _last!,
                cargoPayloadUtf8: _payload.text,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Replay: ${err ?? "unexpected ok"}')),
              );
            },
            child: const Text('Replay (expect ERR_REPLAY_NONCE)'),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<SupplyLine>>(
            future: repo.visiblePodReceipts(),
            builder: (context, snap) {
              final n = snap.data?.length ?? 0;
              return Text(
                'M5.3 — PoD receipts in CRDT ledger: $n (syncs with Mesh sync)',
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          ),
        ],
        const SizedBox(height: 24),
        Text('Scan QR', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: MobileScanner(
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                if (barcodes.isEmpty) return;
                final raw = barcodes.first.rawValue;
                if (raw == null) return;
                final ch = PodChallenge.tryParse(raw);
                setState(() {
                  _scanResult = ch == null ? 'Invalid QR' : 'Parsed delivery ${ch.deliveryId}';
                });
                if (ch != null) {
                  final messenger = ScaffoldMessenger.of(context);
                  pod
                      .finalizeDelivery(
                        ch: ch,
                        cargoPayloadUtf8: _payload.text,
                      )
                      .then((err) {
                    if (!context.mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(err ?? 'Scan: verified + ledger'),
                      ),
                    );
                  });
                }
              },
            ),
          ),
        ),
        if (_scanResult != null) Text(_scanResult!),
        const SizedBox(height: 16),
        Text(
          'Public key: ${id.publicKeyHex?.substring(0, 12) ?? "—"}…',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
