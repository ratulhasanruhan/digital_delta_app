import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/ui_tokens.dart';
import '../../widgets/dd_page_intro.dart';
import '../../core/rbac.dart';
import '../../core/sla.dart';
import '../../crdt/supply_models.dart';
import '../../data/disaster_map_loader.dart';
import '../../data/supply_repository.dart';
import '../identity/services/identity_service.dart';
import '../../routing/simple_route_planner.dart';

/// M6 — SLA tiers, breach prediction, autonomous preemption log.
class TriageHubPage extends StatefulWidget {
  const TriageHubPage({super.key});

  @override
  State<TriageHubPage> createState() => _TriageHubPageState();
}

class _TriageHubPageState extends State<TriageHubPage> {
  double _slowdown = 1.0; // 1.0 = nominal, 1.3 = 30% slower
  Future<DisasterMapData>? _map;
  Future<List<SupplyLine>>? _linesFuture;
  final Set<String> _breachAuditLogged = {};

  @override
  void initState() {
    super.initState();
    _map = DisasterMapData.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _linesFuture ??= context.read<SupplyRepository>().visibleLines();
  }

  Future<void> _reloadLines() async {
    setState(() {
      _linesFuture = context.read<SupplyRepository>().visibleLines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = context.watch<IdentityService>();

    return FutureBuilder<DisasterMapData>(
      future: _map,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final map = snap.data!;

        return FutureBuilder<List<SupplyLine>>(
          future: _linesFuture,
          builder: (context, linesSnap) {
            if (!linesSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final lines = linesSnap.data!;

            return RefreshIndicator(
              onRefresh: _reloadLines,
              child: ListView(
              padding: UiTokens.pageInsets.copyWith(bottom: 28),
              children: [
                DdPageIntro(
                  title: 'Priority & deadlines',
                  description:
                      'Tiers: P0 ≤2h · P1 ≤6h · P2 ≤24h · P3 ≤72h. If the convoy slows by about 30% or more, '
                      'the app flags possible deadline breaches.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Route delay factor vs plan: ${((_slowdown - 1) * 100).round()}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _slowdown,
                  min: 1,
                  max: 2,
                  divisions: 20,
                  label: '${((_slowdown - 1) * 100).round()}%',
                  onChanged: (v) => setState(() => _slowdown = v),
                ),
                if (!id.role.can(Permission.triageOverride))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Read-only: Camp Commander / Sync Admin can execute preemption.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                for (final tier in CargoPriority.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(slaLabel(tier), style: Theme.of(context).textTheme.bodySmall),
                  ),
                const SizedBox(height: 16),
                Text('Cargo SLA evaluation', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final line in lines)
                  _lineCard(context, map, line, id),
              ],
            ),
            );
          },
        );
      },
    );
  }

  Widget _lineCard(
    BuildContext context,
    DisasterMapData map,
    SupplyLine line,
    IdentityService id,
  ) {
    final base = shortestPathMinutes(
      graph: map.graphAllModes(),
      startId: 'N1',
      goalId: line.locationNodeId,
    );
    final baseMins = base?.totalMinutes ?? double.nan;
    final etaMins = baseMins.isFinite ? baseMins * _slowdown : double.infinity;
    final slaH = slaHoursForCargo(line.priority);
    final breach = etaMins.isFinite && etaMins > slaH * 60;
    final severeSlow = _slowdown >= 1.29;
    if (breach && severeSlow && !_breachAuditLogged.contains(line.sku)) {
      _breachAuditLogged.add(line.sku);
      unawaited(
        id.audit.append(
          event: 'sla_breach_predicted',
          payload: {
            'sku': line.sku,
            'priority': line.priority.name,
            'eta_mins': etaMins,
            'sla_h': slaH,
            'slowdown': _slowdown,
            'rationale': 'M6.2 — route ≥30% slower than plan and SLA window exceeded',
          },
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line.description, style: Theme.of(context).textTheme.titleSmall),
            Text('SKU ${line.sku} • ${line.priority.label}'),
            Text(
              'ETA ${etaMins.isFinite ? etaMins.toStringAsFixed(0) : "∞"} min vs SLA ${slaH}h '
              '${breach ? "— BREACH" : "— ok"}',
              style: TextStyle(
                color: breach ? Theme.of(context).colorScheme.error : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (severeSlow && breach && id.role.can(Permission.triageOverride)) ...[
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  await id.audit.append(
                    event: 'preemption_drop_reroute',
                    payload: {
                      'sku': line.sku,
                      'rationale': 'SLA breach with ≥30% slowdown — drop P2/P3 at waypoint, reroute P0/P1',
                      'eta_mins': etaMins,
                    },
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preemption logged to audit chain')),
                    );
                  }
                },
                child: const Text('M6.3 Log drop-and-reroute decision'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
