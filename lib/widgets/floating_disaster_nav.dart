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
    _NavSpec(Icons.local_hospital_rounded, 'Hospital'),
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
        borderRadius: BorderRadius.circular(30),
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
    final pillColor = selected
        ? Color.alphaBlend(
            cs.primary.withValues(alpha: 0.14),
            cs.primaryContainer.withValues(alpha: 0.75),
          )
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: pillColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected ? cs.primary.withValues(alpha: 0.12) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                spec.icon,
                size: selected ? 24 : 22,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: -0.2,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
