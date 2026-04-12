import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/ui_tokens.dart';
import '../../../crdt/conflict_record.dart';
import '../../../crdt/supply_models.dart';
import '../../../crdt/vector_clock.dart';
import '../../../data/supply_repository.dart';
import '../../../features/identity/services/identity_service.dart';
import '../../../network/grpc_sync_client.dart';
import '../../../network/grpc_sync_config.dart';
import '../../../network/grpc_sync_host.dart';
import '../../../network/delta_sync_service.dart';

/// M2 — OR-set supplies, vector clocks, conflict UI, LAN delta sync (gRPC).
class ReliefSuppliesView extends StatefulWidget {
  const ReliefSuppliesView({super.key});

  @override
  State<ReliefSuppliesView> createState() => _ReliefSuppliesViewState();
}

class _ReliefSuppliesViewState extends State<ReliefSuppliesView> {
  final _peerHost = TextEditingController(text: '127.0.0.1');
  GrpcSyncHost? _host;
  DeltaSyncGrpcService? _syncService;
  bool _hosting = false;
  int _gen = 0;

  void _bump() => setState(() => _gen++);

  @override
  void dispose() {
    _peerHost.dispose();
    unawaited(_stopHost());
    super.dispose();
  }

  Future<void> _stopHost() async {
    await _host?.stop();
    _host = null;
    _syncService = null;
    _hosting = false;
  }

  Future<void> _toggleHost(SupplyRepository repo) async {
    if (_hosting) {
      await _stopHost();
      _bump();
      return;
    }
    try {
      _syncService = DeltaSyncGrpcService(repo);
      _host = GrpcSyncHost(_syncService!);
      await _host!.start(port: kDeltaSyncGrpcPort);
      _hosting = true;
      _bump();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync host on :$kDeltaSyncGrpcPort — peer uses this device IP',
            ),
          ),
        );
      }
    } catch (e) {
      await _stopHost();
      _bump();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _push(SupplyRepository repo) async {
    final host = _peerHost.text.trim();
    if (host.isEmpty) return;
    try {
      final ack = await pushSupplyToPeer(repo: repo, host: host, port: kDeltaSyncGrpcPort);
      _bump();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synced · ack seq ${ack.lastSequence}')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _addDemo(SupplyRepository repo) async {
    try {
      await repo.addLine(
        sku: 'KIT-${DateTime.now().millisecondsSinceEpoch % 10000}',
        description: 'Offline OR-set add',
        quantity: 24,
        priority: CargoPriority.p2,
      );
      _bump();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _seedConflict(SupplyRepository repo) async {
    try {
      await repo.seedDemoConflict();
      _bump();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('M2.3 conflict queued — resolve below')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _resolve(
    SupplyRepository repo,
    IdentityService identity,
    CrdtConflict c,
    bool pickLeft,
  ) async {
    try {
      await repo.resolveConflict(conflictId: c.id, pickLeft: pickLeft);
      await identity.audit.append(
        event: 'crdt_conflict_resolved',
        payload: {
          'conflict_id': c.id,
          'field': c.fieldName,
          'choice': pickLeft ? 'left' : 'right',
          'value': pickLeft ? c.leftValue : c.rightValue,
        },
      );
      _bump();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resolution saved + audit logged')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  String _clockShort(VectorClock? vc) {
    if (vc == null) return '—';
    final m = vc.components;
    if (m.isEmpty) return '{}';
    return m.entries.map((e) => '${e.key.substring(0, 6)}…:${e.value}').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final repo = context.watch<SupplyRepository>();
    final identity = context.watch<IdentityService>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'M2 — CRDT supply ledger (OR-Set) · vector clocks · delta sync',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                height: 1.4,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: UiTokens.pageInsets.copyWith(top: 0),
                sliver: SliverList.list(
                  children: [
                    FutureBuilder<VectorClock>(
                      key: const ValueKey('clock'),
                      future: repo.currentClock(),
                      builder: (context, snap) {
                        final vc = snap.data;
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Device vector clock (merge watermark)',
                                style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                vc == null ? '…' : vc.toString(),
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                              ),
                              const SizedBox(height: 8),
                              FutureBuilder<int>(
                                future: repo.estimateDeltaChunkBytes(),
                                builder: (context, b) {
                                  final n = b.data;
                                  final ok = n != null && n < 10240;
                                  return Text(
                                    n == null
                                        ? 'Estimating delta size…'
                                        : 'Full export ≈ $n bytes ${ok ? "(≤10 KB target)" : "(large — add filter in prod)"}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: ok ? cs.primary : cs.tertiary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Peer sync (LAN gRPC)', style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text(
                      'Two phones on the same Wi‑Fi / hotspot: one taps Host, the other enters the host IP and Push. '
                      'Protobuf delta only sends ops the peer has not yet seen (M2.4).',
                      style: GoogleFonts.dmSans(fontSize: 12, color: cs.onSurfaceVariant, height: 1.35),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _peerHost,
                      decoration: InputDecoration(
                        labelText: 'Peer host IP',
                        hintText: 'e.g. 192.168.x.x',
                        prefixIcon: Icon(Icons.dns_rounded, color: cs.primary),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => _toggleHost(repo),
                          icon: Icon(_hosting ? Icons.stop_circle_outlined : Icons.podcasts_rounded),
                          label: Text(_hosting ? 'Stop sync host' : 'Host sync (:$kDeltaSyncGrpcPort)'),
                        ),
                        FilledButton.icon(
                          onPressed: () => _push(repo),
                          icon: const Icon(Icons.sync_rounded),
                          label: const Text('Push delta to peer'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Inventory (OR-Set)', style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 15)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _addDemo(repo),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add line'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FutureBuilder<List<SupplyLine>>(
                      key: const ValueKey('lines'),
                      future: repo.visibleLines(),
                      builder: (context, snap) {
                        final lines = snap.data ?? [];
                        if (lines.isEmpty) {
                          return Text(
                            'No rows yet — tap Add line (or seed conflict after one row).',
                            style: GoogleFonts.dmSans(color: cs.onSurfaceVariant, fontSize: 13),
                          );
                        }
                        return Column(
                          children: [
                            for (final l in lines)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Material(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                l.sku,
                                                style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 16),
                                              ),
                                            ),
                                            Text(
                                              '${l.quantity}',
                                              style: GoogleFonts.dmSans(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          l.description,
                                          style: GoogleFonts.dmSans(fontSize: 12, color: cs.onSurfaceVariant),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Op clock: ${_clockShort(l.causalClock)}',
                                          style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: cs.tertiary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('M2.3 Conflicts', style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 15)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _seedConflict(repo),
                          child: const Text('Seed demo conflict'),
                        ),
                      ],
                    ),
                    FutureBuilder<List<CrdtConflict>>(
                      key: const ValueKey('conflicts'),
                      future: repo.pendingConflicts(),
                      builder: (context, snap) {
                        final list = snap.data ?? [];
                        if (list.isEmpty) {
                          return Text(
                            'No pending conflicts.',
                            style: GoogleFonts.dmSans(fontSize: 12, color: cs.onSurfaceVariant),
                          );
                        }
                        return Column(
                          children: [
                            for (final c in list)
                              Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${c.fieldName}: concurrent edits',
                                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 6),
                                      Text('A: ${c.leftValue}', style: GoogleFonts.dmSans(fontSize: 12)),
                                      Text('B: ${c.rightValue}', style: GoogleFonts.dmSans(fontSize: 12)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          FilledButton.tonal(
                                            onPressed: () => _resolve(repo, identity, c, true),
                                            child: const Text('Keep A'),
                                          ),
                                          const SizedBox(width: 8),
                                          FilledButton.tonal(
                                            onPressed: () => _resolve(repo, identity, c, false),
                                            child: const Text('Keep B'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'BLE / Wi‑Fi Direct: use the Mesh screen for BLE presence; bulk sync uses the framed Protobuf path above on LAN (same rubric family for prototype).',
                      style: GoogleFonts.dmSans(fontSize: 11, color: cs.onSurfaceVariant, height: 1.35),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
