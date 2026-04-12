import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/ui_tokens.dart';

/// Field hospital: wards, beds, triage, pharmacy handoff.
class FieldHospitalView extends StatelessWidget {
  const FieldHospitalView({super.key});

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
                  Expanded(
                    child: _WardCard(
                      cs: cs,
                      name: 'Triage tent',
                      beds: '8 / 12',
                      accent: cs.error,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WardCard(
                      cs: cs,
                      name: 'Post-op',
                      beds: '5 / 8',
                      accent: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Bed occupancy',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.72,
                  minHeight: 10,
                  backgroundColor: cs.surfaceContainerHigh,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '72% · surge capacity 15%',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Triage queue',
                style: GoogleFonts.dmSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _TriageChip(cs: cs, label: 'Red — immediate', count: 4, color: cs.error),
              const SizedBox(height: 8),
              _TriageChip(cs: cs, label: 'Yellow — delayed', count: 11, color: const Color(0xFFCA8A04)),
              const SizedBox(height: 8),
              _TriageChip(cs: cs, label: 'Green — walking wounded', count: 23, color: cs.primary),
              const SizedBox(height: 20),
              Text(
                'Pharmacy & supplies',
                style: GoogleFonts.dmSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  leading: Icon(Icons.medication_rounded, color: cs.tertiary),
                  title: Text(
                    'Antibiotic stocktake',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Last full count queued for sync',
                    style: GoogleFonts.dmSans(fontSize: 12.5),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  leading: Icon(Icons.bloodtype_rounded, color: cs.error),
                  title: Text(
                    'Blood fridge · 4°C log',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Manual readings stored offline',
                    style: GoogleFonts.dmSans(fontSize: 12.5),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Staff on duty',
                style: GoogleFonts.dmSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: CircleAvatar(
                      backgroundColor: cs.primaryContainer,
                      child: Text('M', style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                    label: Text('Dr. Meena · Triage', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                  ),
                  Chip(
                    avatar: CircleAvatar(
                      backgroundColor: cs.secondaryContainer,
                      child: Text('R', style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                    label: Text('Rafi · Logistics', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ],
    );
  }
}

class _WardCard extends StatelessWidget {
  const _WardCard({
    required this.cs,
    required this.name,
    required this.beds,
    required this.accent,
  });

  final ColorScheme cs;
  final String name;
  final String beds;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            beds,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: accent,
            ),
          ),
          Text(
            'beds used',
            style: GoogleFonts.dmSans(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _TriageChip extends StatelessWidget {
  const _TriageChip({
    required this.cs,
    required this.label,
    required this.count,
    required this.color,
  });

  final ColorScheme cs;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$count',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
