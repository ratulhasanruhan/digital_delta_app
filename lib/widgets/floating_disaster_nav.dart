import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Rounded floating bar with elevation, inset from screen edges.
class FloatingDisasterNav extends StatelessWidget {
  const FloatingDisasterNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const _items = <_NavSpec>[
    _NavSpec(Icons.dashboard_rounded, 'Home'),
    _NavSpec(Icons.inventory_2_rounded, 'Supplies'),
    _NavSpec(Icons.flight_takeoff_rounded, 'Drone'),
    _NavSpec(Icons.layers_rounded, 'Risk'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottom * 0.25),
      child: Material(
        color: cs.surface.withValues(alpha: 0.96),
        elevation: 10,
        shadowColor: cs.shadow.withValues(alpha: 0.18),
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: List.generate(_items.length, (i) {
              final spec = _items[i];
              final selected = i == currentIndex;
              return Expanded(
                child: _NavCell(
                  spec: spec,
                  selected: selected,
                  onTap: () => onSelect(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedPill = cs.primary;
    final selectedFg = cs.onPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedPill : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              spec.icon,
              size: 26,
              color: selected ? selectedFg : cs.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: selected ? selectedFg : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
