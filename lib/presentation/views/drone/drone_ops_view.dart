import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/ui_tokens.dart';
import '../../../crdt/supply_models.dart';
import '../../../features/triage/triage_hub_page.dart';
import '../../../widgets/dd_page_intro.dart';
import '../../controllers/shell_controller.dart';

import 'full_route_planner_page.dart';

/// Drone & air ops — compact: routing opens full-screen; sorties in an expansion.
class DroneOpsView extends StatelessWidget {
  const DroneOpsView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: UiTokens.pageInsets,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              DdPageIntro(
                title: 'Drone & air corridor',
                description:
                    'Air legs follow the same priority stack as triage: schedule P0/P1 first when weather and corridor risk allow. '
                    'Open the road-risk tab before dispatch to confirm river and road segments.',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => Scaffold(
                              appBar: AppBar(
                                title: Text(
                                  'Triage & SLA',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              body: const TriageHubPage(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.priority_high_rounded),
                      label: Text(
                        'Triage & SLA',
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () =>
                          context.read<ShellController>().selectTab(3),
                      icon: const Icon(Icons.layers_rounded),
                      label: Text(
                        'Road risk',
                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.map_rounded, color: cs.primary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Routes & hazards',
                              style: GoogleFonts.dmSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Road, river, and air edges with wash-out toggles. Opens full screen.',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const FullRoutePlannerPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_full_rounded),
                        label: Text(
                          'Open route planner',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _FleetPill(
                      cs: cs,
                      name: 'Delta-1',
                      status: 'Ready',
                      battery: 0.78,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FleetPill(
                      cs: cs,
                      name: 'Delta-2',
                      status: 'Charging',
                      battery: 0.42,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    'Mission queue (by cargo priority)',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    'P0/P1 sorties should launch before standard drops when battery and corridor capacity allow.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  children: [
                    _MissionTile(
                      cs: cs,
                      priority: CargoPriority.p0,
                      title: 'Cold-chain relay — insulin',
                      subtitle: 'Air EA1 · N2→N3 · SLA 2h window',
                      status: 'Next up',
                      leadingIcon: Icons.medication_rounded,
                    ),
                    const SizedBox(height: 8),
                    _MissionTile(
                      cs: cs,
                      priority: CargoPriority.p1,
                      title: 'Thermal sweep — Block C',
                      subtitle: 'Upload when mesh uplink available',
                      status: 'Queued',
                      leadingIcon: Icons.document_scanner_rounded,
                    ),
                    const SizedBox(height: 8),
                    _MissionTile(
                      cs: cs,
                      priority: CargoPriority.p2,
                      title: 'Supply drop pin (standard)',
                      subtitle: 'Coords cached offline',
                      status: 'Ready',
                      leadingIcon: Icons.place_rounded,
                    ),
                    const SizedBox(height: 8),
                    _MissionTile(
                      cs: cs,
                      priority: CargoPriority.p3,
                      title: 'Return-to-home calibration',
                      subtitle: 'Battery 78% · non-urgent',
                      status: 'Standby',
                      leadingIcon: Icons.battery_charging_full_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Preflight checklist',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                children: const [
                  _CheckRow(label: 'Geofence & NOTAM cached'),
                  _CheckRow(label: 'Propellers · motors visual'),
                  _CheckRow(label: 'Failsafe RTL verified'),
                ],
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

class _FleetPill extends StatelessWidget {
  const _FleetPill({
    required this.cs,
    required this.name,
    required this.status,
    required this.battery,
  });

  final ColorScheme cs;
  final String name;
  final String status;
  final double battery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w800),
              ),
              Text(
                status,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: battery,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Battery ${(battery * 100).round()}%',
            style: GoogleFonts.dmSans(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({
    required this.cs,
    required this.priority,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.leadingIcon,
  });

  final ColorScheme cs;
  final CargoPriority priority;
  final String title;
  final String subtitle;
  final String status;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    final pColor = switch (priority) {
      CargoPriority.p0 => const Color(0xFFB91C1C),
      CargoPriority.p1 => const Color(0xFFEA580C),
      CargoPriority.p2 => const Color(0xFFCA8A04),
      CargoPriority.p3 => const Color(0xFF64748B),
    };
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer.withValues(alpha: 0.5),
          child: Icon(leadingIcon, color: cs.primary, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: pColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: pColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                priority.label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: pColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12)),
          ],
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: cs.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: CheckboxListTile(
          value: true,
          onChanged: (_) {},
          title: Text(
            label,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
}
