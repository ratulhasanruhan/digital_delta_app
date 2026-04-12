import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/app_theme.dart';
import '../../../app/ui_tokens.dart';

/// Relief logistics: search, category chips, stock rows, dispatch summary.
class ReliefSuppliesView extends StatefulWidget {
  const ReliefSuppliesView({super.key});

  @override
  State<ReliefSuppliesView> createState() => _ReliefSuppliesViewState();
}

class _ReliefSuppliesViewState extends State<ReliefSuppliesView> {
  final _search = TextEditingController();
  int _chip = 0;

  static const _filters = ['All', 'Critical', 'Medical', 'Shelter'];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final items = [
      _SupplyRow('Dry rations', 'Cartons · Zone A', '240', 0.82, Icons.breakfast_dining_rounded, cs.primary),
      _SupplyRow('Potable water', 'Litres · depots', '18.5k', 0.64, Icons.water_drop_rounded, AppTheme.waterAccent),
      _SupplyRow('Medical kits', 'IFAK + trauma', '86', 0.45, Icons.medical_services_rounded, cs.error),
      _SupplyRow('Tarp & rope', 'Shelter kits', '320', 0.91, Icons.cabin_rounded, const Color(0xFFCA8A04)),
      _SupplyRow('Hygiene packs', 'Family units', '410', 0.55, Icons.soap_rounded, const Color(0xFF7C3AED)),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: 'Search SKU, depot, batch…',
              prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
              isDense: true,
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final sel = i == _chip;
              return FilterChip(
                label: Text(_filters[i]),
                selected: sel,
                onSelected: (_) => setState(() => _chip = i),
                showCheckmark: false,
                labelStyle: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: sel ? cs.onSecondaryContainer : cs.onSurfaceVariant,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: UiTokens.pageInsets.copyWith(top: 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      'Stock levels update offline; server merges on sync.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        height: 1.45,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...items.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SupplyCard(row: r, cs: cs),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Material(
          elevation: 8,
          shadowColor: cs.shadow.withValues(alpha: 0.12),
          color: cs.surface,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ready to dispatch',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '18 pallets · 6 routes planned',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.local_shipping_rounded, size: 20),
                    label: Text('Plan run', style: GoogleFonts.dmSans(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SupplyRow {
  const _SupplyRow(
    this.title,
    this.subtitle,
    this.qty,
    this.fill,
    this.icon,
    this.accent,
  );
  final String title;
  final String subtitle;
  final String qty;
  final double fill;
  final IconData icon;
  final Color accent;
}

class _SupplyCard extends StatelessWidget {
  const _SupplyCard({required this.row, required this.cs});

  final _SupplyRow row;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: row.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(row.icon, color: row.accent, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.title,
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        Text(
                          row.subtitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        row.qty,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'on hand',
                        style: GoogleFonts.dmSans(fontSize: 11, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: row.fill,
                  minHeight: 6,
                  backgroundColor: cs.surfaceContainerHigh,
                  color: row.accent.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Target fill ${(row.fill * 100).round()}% · policy min 40%',
                style: GoogleFonts.dmSans(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
