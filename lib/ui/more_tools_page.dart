import 'package:flutter/material.dart';

import '../app/navigation_labels.dart';
import '../app/operator_destination.dart';
import '../app/ui_tokens.dart';
import '../widgets/dd_page_intro.dart';
import '../widgets/dd_section_header.dart';

/// One place to open every field workflow (delivery, priorities, fleet, relay, flood, security).
class MoreToolsPage extends StatelessWidget {
  const MoreToolsPage({super.key, required this.onOpen});

  final void Function(OperatorDestination dest) onOpen;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final items = <_ToolItem>[
      _ToolItem(
        dest: OperatorDestination.triage,
        icon: Icons.health_and_safety_outlined,
        title: NavLabels.title(OperatorDestination.triage),
        subtitle: 'See urgent cargo and deadline risk before you roll.',
      ),
      _ToolItem(
        dest: OperatorDestination.pod,
        icon: Icons.qr_code_2_outlined,
        title: NavLabels.title(OperatorDestination.pod),
        subtitle: 'Scan or show a QR to confirm a handoff without internet.',
      ),
      _ToolItem(
        dest: OperatorDestination.fleet,
        icon: Icons.flight_outlined,
        title: NavLabels.title(OperatorDestination.fleet),
        subtitle: 'Trucks, boats, drones, and meet points for pickup.',
      ),
      _ToolItem(
        dest: OperatorDestination.relay,
        icon: Icons.route_outlined,
        title: NavLabels.title(OperatorDestination.relay),
        subtitle: 'Send sealed messages that volunteers can carry hop-by-hop.',
      ),
      _ToolItem(
        dest: OperatorDestination.modules,
        icon: Icons.water_drop_outlined,
        title: NavLabels.title(OperatorDestination.modules),
        subtitle: 'Estimate flood risk on a route leg before it fails.',
      ),
      _ToolItem(
        dest: OperatorDestination.identity,
        icon: Icons.verified_user_outlined,
        title: NavLabels.title(OperatorDestination.identity),
        subtitle: 'Your keys, role, and tamper-evident activity log.',
      ),
    ];

    return ListView(
      padding: UiTokens.pageInsets.copyWith(bottom: 28),
      children: [
        DdPageIntro(
          title: 'All tools',
          description:
              'Everything here works offline. Sync when you are near another team device or on local Wi‑Fi.',
        ),
        const SizedBox(height: 20),
        DdSectionHeader(
          title: 'Workflows',
          subtitle: 'Tap a card to open. Use the bottom bar or drawer anytime.',
        ),
        const SizedBox(height: 6),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: cs.surfaceContainerHighest,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.45)),
              ),
              child: InkWell(
                onTap: () => onOpen(item.dest),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: cs.primaryContainer,
                        child: Icon(item.icon, color: cs.onPrimaryContainer, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: cs.outline),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ToolItem {
  const _ToolItem({
    required this.dest,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final OperatorDestination dest;
  final IconData icon;
  final String title;
  final String subtitle;
}
