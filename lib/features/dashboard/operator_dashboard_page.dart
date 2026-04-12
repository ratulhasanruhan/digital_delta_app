import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/operator_destination.dart';
import '../../app/ui_tokens.dart';
import '../../core/rbac.dart';
import '../../data/supply_repository.dart';
import '../../features/identity/services/identity_service.dart';
import '../../features/mesh/relay_service.dart';
import '../../widgets/dd_section_header.dart';

/// Field operations home: situational summary, quick actions, and workflow entry points.
class OperatorDashboardPage extends StatelessWidget {
  const OperatorDashboardPage({super.key, required this.onOpen});

  final void Function(OperatorDestination dest) onOpen;

  static const List<OperatorDestination> _respondNow = [
    OperatorDestination.map,
    OperatorDestination.supply,
    OperatorDestination.mesh,
  ];

  static const List<OperatorDestination> _deliverVerify = [
    OperatorDestination.pod,
    OperatorDestination.relay,
  ];

  static const List<OperatorDestination> _planPrioritize = [
    OperatorDestination.triage,
    OperatorDestination.fleet,
    OperatorDestination.modules,
  ];

  @override
  Widget build(BuildContext context) {
    final id = context.watch<IdentityService>();
    final repo = context.watch<SupplyRepository>();
    final relay = context.watch<MeshRelayService>();

    return FutureBuilder<_DashStats>(
      future: _loadStats(repo, relay),
      builder: (context, snap) {
        final stats = snap.data;
        return LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth > 720;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    UiTokens.pageH,
                    20,
                    UiTokens.pageH,
                    12,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _MissionBanner(
                      roleLabel: id.role.label,
                      replicaShort: repo.replicaId.length > 14
                          ? '${repo.replicaId.substring(0, 14)}…'
                          : repo.replicaId,
                      stats: stats,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 0, UiTokens.pageH, 12),
                  sliver: SliverToBoxAdapter(
                    child: OutlinedButton.icon(
                      onPressed: () => onOpen(OperatorDestination.tools),
                      icon: const Icon(Icons.grid_view_rounded),
                      label: const Text('Browse all tools'),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 0, UiTokens.pageH, 4),
                  sliver: SliverToBoxAdapter(
                    child: DdSectionHeader(
                      title: 'Respond now',
                      subtitle: 'Open map, supply, or sync with a peer.',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 0, UiTokens.pageH, 16),
                  sliver: SliverToBoxAdapter(
                    child: wide
                        ? Row(
                            children: [
                              for (final d in _respondNow)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: _QuickActionButton(
                                      dest: d,
                                      onTap: () => onOpen(d),
                                      restricted: _isRestricted(d, id.role),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            children: [
                              for (final d in _respondNow)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _QuickActionButton(
                                    dest: d,
                                    onTap: () => onOpen(d),
                                    restricted: _isRestricted(d, id.role),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 12, UiTokens.pageH, 4),
                  sliver: SliverToBoxAdapter(
                    child: DdSectionHeader(
                      title: 'Deliver & verify',
                      subtitle: 'QR handoffs and encrypted relay messages.',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 0, UiTokens.pageH, 8),
                  sliver: _DestGrid(
                    destinations: _deliverVerify,
                    onOpen: onOpen,
                    role: id.role,
                    crossAxisCount: c.maxWidth > 900 ? 3 : c.maxWidth > 520 ? 2 : 1,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 12, UiTokens.pageH, 4),
                  sliver: SliverToBoxAdapter(
                    child: DdSectionHeader(
                      title: 'Plan & prioritize',
                      subtitle: 'Deadlines, fleet, and flood risk on route legs.',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 0, UiTokens.pageH, 8),
                  sliver: _DestGrid(
                    destinations: _planPrioritize,
                    onOpen: onOpen,
                    role: id.role,
                    crossAxisCount: c.maxWidth > 900 ? 3 : c.maxWidth > 520 ? 2 : 1,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 12, UiTokens.pageH, 4),
                  sliver: SliverToBoxAdapter(
                    child: DdSectionHeader(
                      title: 'Account & safety',
                      subtitle: 'Keys, role, and audit trail on this device.',
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 0, UiTokens.pageH, 32),
                  sliver: _DestGrid(
                    destinations: const [OperatorDestination.identity],
                    onOpen: onOpen,
                    role: id.role,
                    crossAxisCount: c.maxWidth > 520 ? 2 : 1,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<_DashStats> _loadStats(SupplyRepository repo, MeshRelayService relay) async {
    final lines = await repo.visibleLines();
    final conflicts = await repo.pendingConflictCount();
    final pending = await repo.relayPendingRows();
    return _DashStats(
      supplyLines: lines.length,
      pendingConflicts: conflicts,
      relayPending: pending.length,
    );
  }

  static bool _isRestricted(OperatorDestination d, UserRole r) {
    if (d == OperatorDestination.mesh && !r.can(Permission.executeSync)) return true;
    return false;
  }
}

class _MissionBanner extends StatelessWidget {
  const _MissionBanner({
    required this.roleLabel,
    required this.replicaShort,
    required this.stats,
  });

  final String roleLabel;
  final String replicaShort;
  final _DashStats? stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primaryContainer.withValues(alpha: 0.65),
              cs.surfaceContainerHighest.withValues(alpha: 0.9),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primary.withValues(alpha: 0.12),
                  child: Icon(Icons.shield_outlined, color: cs.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offline disaster logistics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Routes, inventory, and handoffs stay on your device and sync when you are in range of another team. '
                        'Commercial internet is not required for core work.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatChip(icon: Icons.badge_outlined, label: roleLabel),
                _StatChip(icon: Icons.fingerprint, label: 'Device $replicaShort'),
                if (stats != null) ...[
                  _StatChip(
                    icon: Icons.inventory_2_outlined,
                    label: '${stats!.supplyLines} supply lines',
                  ),
                  _StatChip(
                    icon: Icons.merge_type,
                    label: '${stats!.pendingConflicts} merge review${stats!.pendingConflicts == 1 ? "" : "s"}',
                    emphasize: stats!.pendingConflicts > 0,
                  ),
                  _StatChip(
                    icon: Icons.outbox_outlined,
                    label: '${stats!.relayPending} queued relay',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.dest,
    required this.onTap,
    required this.restricted,
  });

  final OperatorDestination dest;
  final VoidCallback onTap;
  final bool restricted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (icon, title, subtitle) = _quickMeta(dest);
    return FilledButton.tonal(
      onPressed: restricted ? null : onTap,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(80),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: restricted ? cs.outline : cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: restricted ? cs.onSurface.withValues(alpha: 0.45) : null,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  restricted ? 'Not permitted for your role' : subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: restricted
                            ? cs.error
                            : cs.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: cs.outline),
        ],
      ),
    );
  }

  static (IconData, String, String) _quickMeta(OperatorDestination d) => switch (d) {
        OperatorDestination.map => (
            Icons.map_outlined,
            'Routes & map',
            'Roads, rivers, air legs; replan when something closes',
          ),
        OperatorDestination.supply => (
            Icons.inventory_2_outlined,
            'Supply ledger',
            'What is committed, merged from peers, and pending review',
          ),
        OperatorDestination.mesh => (
            Icons.sync_alt_outlined,
            'Peer sync',
            'Exchange updates with another device on Wi‑Fi / LAN',
          ),
        _ => (Icons.open_in_new, '', ''),
      };
}

class _DestGrid extends StatelessWidget {
  const _DestGrid({
    required this.destinations,
    required this.onOpen,
    required this.role,
    required this.crossAxisCount,
  });

  final List<OperatorDestination> destinations;
  final void Function(OperatorDestination dest) onOpen;
  final UserRole role;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 118,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, i) {
        final dest = destinations[i];
        final restricted = OperatorDashboardPage._isRestricted(dest, role);
        final (title, subtitle, icon) = _workflowMeta(dest);
        return _DashCard(
          title: title,
          subtitle: subtitle,
          icon: icon,
          dimmed: restricted,
          onTap: () => onOpen(dest),
        );
      },
    );
  }

  static (String, String, IconData) _workflowMeta(OperatorDestination d) => switch (d) {
        OperatorDestination.pod => (
            'Proof of delivery',
            'Signed QR handoff between driver and camp',
            Icons.qr_code_2_outlined,
          ),
        OperatorDestination.relay => (
            'Encrypted relay',
            'Messages that hop through volunteers; content stays sealed',
            Icons.route_outlined,
          ),
        OperatorDestination.triage => (
            'Priority & deadlines',
            'Medical vs standard cargo; SLA breach and reroute hints',
            Icons.health_and_safety_outlined,
          ),
        OperatorDestination.fleet => (
            'Fleet & handoff',
            'Truck, boat, drone zones and meet points',
            Icons.flight_outlined,
          ),
        OperatorDestination.modules => (
            'Flood & route risk',
            'Rain and terrain cues before a leg fails',
            Icons.water_outlined,
          ),
        OperatorDestination.identity => (
            'Security & identity',
            'Keys, role, audit log, integrity check',
            Icons.verified_user_outlined,
          ),
        _ => ('', '', Icons.circle_outlined),
      };
}

class _DashStats {
  _DashStats({
    required this.supplyLines,
    required this.pendingConflicts,
    required this.relayPending,
  });

  final int supplyLines;
  final int pendingConflicts;
  final int relayPending;
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 18, color: emphasize ? cs.error : cs.primary),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      backgroundColor: emphasize ? cs.errorContainer.withValues(alpha: 0.35) : cs.surfaceContainerHigh,
      side: BorderSide(color: cs.outlineVariant.withValues(alpha: emphasize ? 0.5 : 0.35)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}

class _DashCard extends StatelessWidget {
  const _DashCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.dimmed = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: dimmed ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: cs.surfaceContainerHighest,
                child: Icon(icon, color: dimmed ? cs.outline : cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: dimmed ? cs.onSurface.withValues(alpha: 0.45) : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: dimmed ? cs.onSurfaceVariant.withValues(alpha: 0.6) : cs.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}
