import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/app_theme.dart';
import '../../../app/ui_tokens.dart';

/// UAV operations: fleet strip, next sortie, mission queue, safety checklist.
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
              Row(
                children: [
                  Expanded(child: _FleetPill(cs: cs, name: 'Delta-1', status: 'Ready', battery: 0.78)),
                  const SizedBox(width: 10),
                  Expanded(child: _FleetPill(cs: cs, name: 'Delta-2', status: 'Charging', battery: 0.42)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.floodDeep.withValues(alpha: 0.85),
                      const Color(0xFF4F46E5).withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flight_rounded, color: Colors.white, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next sortie window',
                            style: GoogleFonts.dmSans(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '14:20 — River bend survey',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.floodDeep,
                      ),
                      onPressed: () {},
                      child: Text('Schedule', style: GoogleFonts.dmSans(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surfaceContainerHighest,
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, color: cs.primary, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Flight corridor preview (offline tiles)',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Queued missions',
                style: GoogleFonts.dmSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _MissionTile(
                cs: cs,
                title: 'Thermal sweep — Block C',
                subtitle: 'Pending upload · 42 photos',
                status: 'Queued',
                leadingIcon: Icons.document_scanner_rounded,
              ),
              const SizedBox(height: 10),
              _MissionTile(
                cs: cs,
                title: 'Supply drop pin',
                subtitle: 'Coords cached offline',
                status: 'Ready',
                leadingIcon: Icons.place_rounded,
              ),
              const SizedBox(height: 10),
              _MissionTile(
                cs: cs,
                title: 'Return-to-home test',
                subtitle: 'Battery 78%',
                status: 'Standby',
                leadingIcon: Icons.battery_charging_full_rounded,
              ),
              const SizedBox(height: 20),
              Text(
                'Preflight (tap to toggle)',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const _CheckRow(label: 'Geofence & NOTAM cached'),
              const _CheckRow(label: 'Propellers · motors visual'),
              const _CheckRow(label: 'Failsafe RTL verified'),
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
              Text(name, style: GoogleFonts.dmSans(fontWeight: FontWeight.w800)),
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
    required this.title,
    required this.subtitle,
    required this.status,
    required this.leadingIcon,
  });

  final ColorScheme cs;
  final String title;
  final String subtitle;
  final String status;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer.withValues(alpha: 0.5),
          child: Icon(leadingIcon, color: cs.primary),
        ),
        title: Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12.5)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: GoogleFonts.dmSans(
              fontSize: 11,
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
          title: Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14)),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
}
