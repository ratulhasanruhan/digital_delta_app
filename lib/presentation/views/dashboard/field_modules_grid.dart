import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/app_theme.dart';
import '../../../features/fleet/fleet_hub_page.dart';
import '../../../features/identity/ui/identity_hub_page.dart';
import '../../../features/mesh/relay_hub_page.dart';
import '../../../features/pod/pod_hub_page.dart';
import '../../../features/triage/triage_hub_page.dart';
import '../../controllers/shell_controller.dart';
import '../drone/full_route_planner_page.dart';

/// One-tap access to M1–M8 tools from the dashboard.
class FieldModulesGrid extends StatelessWidget {
  const FieldModulesGrid({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  void _openSuppliesTab(BuildContext context) {
    context.read<ShellController>().selectTab(1);
  }

  void _openRoadRiskTab(BuildContext context) {
    context.read<ShellController>().selectTab(3);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Field modules',
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'M1–M8: tap to open. Supplies stays on the bottom tab.',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final cross = w > 560 ? 3 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cross,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: w > 560 ? 1.45 : 1.38,
              children: [
                _Tile(
                  icon: Icons.shield_rounded,
                  title: 'Identity',
                  subtitle: 'M1',
                  tint: AppTheme.brandGreen,
                  onTap: () => _open(
                    context,
                    Scaffold(
                      appBar: AppBar(
                        title: Text('Security', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                      ),
                      body: const IdentityHubPage(),
                    ),
                  ),
                ),
                _Tile(
                  icon: Icons.inventory_2_rounded,
                  title: 'Supplies',
                  subtitle: 'M2 sync',
                  tint: AppTheme.waterAccent,
                  onTap: () => _openSuppliesTab(context),
                ),
                _Tile(
                  icon: Icons.hub_rounded,
                  title: 'Mesh relay',
                  subtitle: 'M3',
                  tint: const Color(0xFF6366F1),
                  onTap: () => _open(context, const RelayHubPage()),
                ),
                _Tile(
                  icon: Icons.map_rounded,
                  title: 'Routes',
                  subtitle: 'M4',
                  tint: const Color(0xFFEA580C),
                  onTap: () => _open(context, const FullRoutePlannerPage()),
                ),
                _Tile(
                  icon: Icons.verified_rounded,
                  title: 'Proof of delivery',
                  subtitle: 'M5',
                  tint: cs.primary,
                  onTap: () => _open(
                    context,
                    Scaffold(
                      appBar: AppBar(
                        title: Text('Proof of delivery', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                      ),
                      body: const PodHubPage(),
                    ),
                  ),
                ),
                _Tile(
                  icon: Icons.priority_high_rounded,
                  title: 'Triage',
                  subtitle: 'M6',
                  tint: cs.error,
                  onTap: () => _open(
                    context,
                    Scaffold(
                      appBar: AppBar(
                        title: Text('Triage & SLA', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                      ),
                      body: const TriageHubPage(),
                    ),
                  ),
                ),
                _Tile(
                  icon: Icons.layers_rounded,
                  title: 'Road risk',
                  subtitle: 'M7 ML map',
                  tint: AppTheme.floodDeep,
                  onTap: () => _openRoadRiskTab(context),
                ),
                _Tile(
                  icon: Icons.directions_boat_rounded,
                  title: 'Fleet',
                  subtitle: 'M8',
                  tint: const Color(0xFF7C3AED),
                  onTap: () => _open(
                    context,
                    Scaffold(
                      appBar: AppBar(
                        title: Text('Fleet & handoff', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                      ),
                      body: const FleetHubPage(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: tint, size: 22),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
