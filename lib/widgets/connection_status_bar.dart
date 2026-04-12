import 'package:flutter/material.dart';

import '../app/sync_status_controller.dart';

/// Track A5 — always-visible strip for offline / sync / conflict / verified.
class ConnectionStatusBar extends StatelessWidget {
  const ConnectionStatusBar({super.key, required this.controller});

  final SyncStatusController controller;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final s = controller.surface;
        final (icon, label, color) = _visuals(context, s);
        return Semantics(
          label: 'Connection status: $label',
          child: Material(
            elevation: 0,
            color: color.withValues(alpha: 0.1),
            child: InkWell(
              onTap: () => _showSheet(context, s),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: outline),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 20, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                      ),
                    ),
                    Icon(Icons.info_outline_rounded, size: 20, color: color.withValues(alpha: 0.85)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  (IconData, String, Color) _visuals(BuildContext context, SyncSurfaceState s) {
    final cs = Theme.of(context).colorScheme;
    return switch (s) {
      SyncSurfaceState.offline => (Icons.cloud_off_outlined, 'Offline — changes stay on this device', cs.error),
      SyncSurfaceState.syncing => (Icons.sync_rounded, 'Syncing with peer…', cs.primary),
      SyncSurfaceState.conflict => (Icons.warning_amber_rounded, 'Conflict — review in Supply', cs.tertiary),
      SyncSurfaceState.verified => (Icons.verified_outlined, 'Verified', cs.secondary),
      SyncSurfaceState.online => (Icons.cloud_done_outlined, 'Ready to sync', cs.primary),
    };
  }

  void _showSheet(BuildContext context, SyncSurfaceState s) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sync & connectivity', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(
                switch (s) {
                  SyncSurfaceState.offline =>
                    'No uplink. Your edits stay on-device; use Sync when you meet another device on Wi‑Fi.',
                  SyncSurfaceState.syncing =>
                    'Applying shared updates. Keep the app open until this finishes.',
                  SyncSurfaceState.conflict =>
                    'Two devices edited the same item. Resolve it in Supply ledger.',
                  SyncSurfaceState.verified =>
                    'Cryptographic check succeeded (delivery or identity).',
                  SyncSurfaceState.online =>
                    'You can run a mesh sync from the Sync tab.',
                },
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }
}
