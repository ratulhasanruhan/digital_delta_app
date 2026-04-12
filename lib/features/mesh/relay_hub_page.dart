import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../app/ui_tokens.dart';
import '../../widgets/dd_page_intro.dart';
import '../identity/services/identity_service.dart';
import 'mesh_node_role.dart';
import 'relay_service.dart';

/// M3 — store-and-forward (A→B→C), dual-role heuristics, E2E sealed payloads.
class RelayHubPage extends StatefulWidget {
  const RelayHubPage({super.key});

  @override
  State<RelayHubPage> createState() => _RelayHubPageState();
}

class _RelayHubPageState extends State<RelayHubPage> {
  final _eval = MeshNodeRoleEvaluator();
  double _rssiDbm = -72;
  MeshNodeMode? _lastMode;
  int? _batteryPct;

  @override
  void initState() {
    super.initState();
    _loadBattery();
  }

  Future<void> _loadBattery() async {
    try {
      final pct = await Battery().batteryLevel;
      if (mounted) setState(() => _batteryPct = pct);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final relay = context.watch<MeshRelayService>();
    final id = context.watch<IdentityService>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mesh relay', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: UiTokens.pageInsets.copyWith(bottom: 28),
        children: [
          DdPageIntro(
            title: 'Module 3 — mesh relay',
            description:
                'M3.1: sealed frame moves from device A to relay B to recipient C; pause B mid-relay and resume. '
                'M3.2: role switches from battery + signal. M3.3: relays see opaque bytes only — decrypt needs the recipient key.',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('M3.2 heuristics', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Battery: ${_batteryPct ?? "—"}%', style: Theme.of(context).textTheme.bodyMedium),
                  Text('Simulated RSSI (dBm): ${_rssiDbm.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium),
                  Slider(
                    value: _rssiDbm.clamp(-100, -40),
                    min: -100,
                    max: -40,
                    divisions: 60,
                    label: '${_rssiDbm.round()} dBm',
                    onChanged: (v) => setState(() => _rssiDbm = v),
                  ),
                  FilledButton.tonal(
                    onPressed: () async {
                      final mode = await _eval.evaluate(simulatedRssiDbm: _rssiDbm);
                      relay.logRoleSwitch(mode == MeshNodeMode.relay ? 'auto_relay' : 'auto_client');
                      if (mounted) setState(() => _lastMode = mode);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Mode: ${mode == MeshNodeMode.relay ? "RELAY" : "CLIENT"}')),
                        );
                      }
                    },
                    child: const Text('Evaluate node mode'),
                  ),
                  if (_lastMode != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Last: ${_lastMode == MeshNodeMode.relay ? "Relay (can forward)" : "Client (receive / conserve)"}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('M3.1 flow (same device simulates A → B → C)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () async {
              try {
                final pk = await id.publicKeyBytes;
                await relay.enqueueSealed(
                  recipientPublicKeyBytes: pk,
                  plaintextUtf8: 'HELLO|${DateTime.now().toIso8601String()}|m3',
                );
                relay.logRoleSwitch('client');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Frame enqueued at A (origin)')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
              }
            },
            icon: const Icon(Icons.outbond_rounded),
            label: const Text('1 · Create at device A (sealed for C)'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () async {
              final m = relay.firstAtOrigin;
              if (m == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No frame at origin')),
                );
                return;
              }
              await relay.advanceOriginToRelay(m.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('A → B: opaque forward (relay cannot read plaintext)')),
                );
              }
            },
            child: const Text('2 · Forward A → relay B'),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Pause relay B (mid-relay)'),
            subtitle: const Text('While paused, B → C is blocked; TTL still counts down'),
            value: relay.relayPaused,
            onChanged: relay.setRelayPaused,
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () async {
              final m = relay.firstAtRelay;
              if (m == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No frame at relay')),
                );
                return;
              }
              if (relay.relayPaused) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Relay paused — unpause first (M3.1 mid-relay)')),
                );
                return;
              }
              await relay.advanceRelayToRecipient(m.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('B → C: frame ready at recipient')),
                );
              }
            },
            child: const Text('3 · Forward relay B → recipient C'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              final id = Uuid().v4();
              final first = relay.claimRelayDeliveryId(id);
              final second = relay.claimRelayDeliveryId(id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('M3.1 dedup at relay: first=$first second=$second')),
              );
            },
            child: const Text('Demo dedup (same id twice at relay)'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final pk = await id.publicKeyBytes;
              final fp = MeshRelayService.fingerprintPublicKey(pk);
              final m = relay.peekForDest(fp);
              if (m == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No frame at recipient (complete steps 1–3)')),
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
            icon: const Icon(Icons.lock_open_rounded),
            label: const Text('4 · Decrypt at C & ACK'),
          ),
          const SizedBox(height: 16),
          Text('M3.3 packet inspection', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final m in relay.pending)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text('id ${m.id.substring(0, 8)}…', style: Theme.of(context).textTheme.titleSmall),
                subtitle: Text(
                  '${_holderLabel(m.holder)} · hops ${m.hopCount} · TTL ${m.ttlSeconds}s',
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      m.sealedPayloadJson.length > 200
                          ? '${m.sealedPayloadJson.substring(0, 200)}…'
                          : m.sealedPayloadJson,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await relay.decryptWithWrongKeyForDemo(m.sealedPayloadJson);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Wrong key → MAC fails (expected): $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Try decrypt with random key (should fail)'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text('Queue (${relay.pending.length})', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (relay.pending.isEmpty)
            Text('Empty', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          Text('Role log', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          for (final e in relay.roleHistory.take(12))
            ListTile(
              dense: true,
              title: Text(e.value),
              subtitle: Text(e.key),
            ),
        ],
      ),
    );
  }

  String _holderLabel(RelayHolder h) {
    switch (h) {
      case RelayHolder.origin:
        return 'At A (origin)';
      case RelayHolder.relay:
        return 'At B (relay)';
      case RelayHolder.recipient:
        return 'At C (recipient)';
    }
  }
}
