import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/app_theme.dart';
import '../../../app/sync_status_controller.dart';
import '../../../app/ui_tokens.dart';
import '../../../features/identity/ui/identity_hub_page.dart';
import 'field_modules_grid.dart';
import '../../../widgets/connection_status_bar.dart';
import '../../controllers/auth_controller.dart';

/// Situation room: sync strip, KPIs, river level, activity feed, quick actions.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = Get.find<AuthController>();

    return Consumer<SyncStatusController>(
      builder: (context, sync, _) {
        return Obx(
          () {
            final phone = auth.phoneDisplay.value;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: UiTokens.pageInsets,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ConnectionStatusBar(controller: sync),
                      const SizedBox(height: 16),
                      _WelcomeCard(phone: phone, cs: cs, sync: sync),
                  const SizedBox(height: 12),
                  _SecurityAuditTile(cs: cs),
                  const SizedBox(height: UiTokens.sectionGap),
                  const FieldModulesGrid(),
                  const SizedBox(height: UiTokens.sectionGap),
                  Text(
                    'Live priorities',
                    style: GoogleFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth;
                      final cross = w > 520 ? 4 : 2;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: cross,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.12,
                        children: const [
                          _StatTile(
                            icon: Icons.warning_amber_rounded,
                            label: 'Active alerts',
                            value: '12',
                            tint: Color(0xFFEA580C),
                          ),
                          _StatTile(
                            icon: Icons.groups_rounded,
                            label: 'Shelters',
                            value: '48',
                            tint: AppTheme.waterAccent,
                          ),
                          _StatTile(
                            icon: Icons.inventory_rounded,
                            label: 'Supply kits',
                            value: '1.2k',
                            tint: AppTheme.brandGreen,
                          ),
                          _StatTile(
                            icon: Icons.flight_rounded,
                            label: 'Drone sorties',
                            value: '7',
                            tint: Color(0xFF7C3AED),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: UiTokens.sectionGap),
                  _RiverLevelCard(cs: cs),
                  const SizedBox(height: UiTokens.sectionGap),
                  Text(
                    'Recent activity',
                    style: GoogleFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _ActivityTile(
                    icon: Icons.sync_rounded,
                    title: 'Relief manifest queued',
                    subtitle: 'Will upload when signal improves',
                    time: '2m ago',
                  ),
                  const SizedBox(height: 8),
                  const _ActivityTile(
                    icon: Icons.emergency_rounded,
                    title: 'Medevac request drafted',
                    subtitle: 'Coordinator queue · awaiting air slot',
                    time: '18m ago',
                  ),
                  const SizedBox(height: 8),
                  const _ActivityTile(
                    icon: Icons.flight_takeoff_rounded,
                    title: 'Thermal sweep archived',
                    subtitle: '42 images · stored on device',
                    time: '1h ago',
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RiverLevelCard extends StatelessWidget {
  const _RiverLevelCard({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppTheme.waterAccent.withValues(alpha: 0.12),
        border: Border.all(color: AppTheme.waterAccent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.waves_rounded, color: AppTheme.floodDeep, size: 24),
              const SizedBox(width: 10),
              Text(
                'River stage (nearest gauge)',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.78,
              minHeight: 10,
              backgroundColor: cs.surfaceContainerHigh,
              color: AppTheme.floodDeep,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '78% of flood stage',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Watch',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFEA580C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: cs.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityAuditTile extends StatelessWidget {
  const _SecurityAuditTile({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text('Security & audit', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                ),
                body: const IdentityHubPage(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: cs.primary, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security & audit trail',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'TOTP, keys, hash-chained login log — tap to open',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    this.phone,
    required this.cs,
    required this.sync,
  });

  final String? phone;
  final ColorScheme cs;
  final SyncStatusController sync;

  @override
  Widget build(BuildContext context) {
    final online = !sync.isOffline;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.floodDeep,
            cs.primary.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.floodDeep.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      online ? Icons.wifi_rounded : Icons.cloud_off_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      online ? 'Network online' : 'Offline mode',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Operations overview',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            phone != null
                ? (online
                    ? 'Signed in as $phone · Network available — use Supplies for peer sync (central admin is separate).'
                    : 'Signed in as $phone · Changes stay on-device until you’re online or sync with a peer.')
                : (online
                    ? 'Network available — open Supplies to sync with another device.'
                    : 'Queue actions on-device until connectivity is back.'),
            style: GoogleFonts.dmSans(
              fontSize: 14,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: cs.onSurface,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
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

