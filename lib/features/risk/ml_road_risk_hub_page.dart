import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app/ui_tokens.dart';
import '../../data/disaster_map_loader.dart';
import '../../presentation/views/drone/full_route_planner_page.dart';
import '../../routing/typed_route_planner.dart';
import '../../widgets/dd_page_intro.dart';
import 'edge_risk_dialog.dart';
import 'risk_map_utils.dart';
import 'route_risk_controller.dart';

/// M7 — full-screen road risk: map, legend, sorted edge list, weather controls.
class MlRoadRiskHubPage extends StatefulWidget {
  const MlRoadRiskHubPage({super.key});

  @override
  State<MlRoadRiskHubPage> createState() => _MlRoadRiskHubPageState();
}

class _MlRoadRiskHubPageState extends State<MlRoadRiskHubPage> {
  Future<DisasterMapData>? _mapFut;
  final MapController _mapCtl = MapController();
  bool _primed = false;
  String _modeFilter = 'all'; // all | road | river | air

  @override
  void initState() {
    super.initState();
    _mapFut = DisasterMapData.load();
  }

  Iterable<TypedEdge> _visibleEdges(DisasterMapData map) {
    if (_modeFilter == 'all') return map.typedEdges;
    return map.typedEdges.where((e) => e.mode == _modeFilter);
  }

  void _onInputsChanged(DisasterMapData map, RouteRiskController risk) {
    risk.recompute(map);
  }

  ({double avg, double max, int high, int n}) _stats(
    DisasterMapData map,
    RouteRiskController risk,
  ) {
    final edges = _visibleEdges(map).toList();
    if (edges.isEmpty) {
      return (avg: 0, max: 0, high: 0, n: 0);
    }
    var sum = 0.0;
    var max = 0.0;
    var high = 0;
    for (final e in edges) {
      final p = risk.riskForEdge(e.id);
      sum += p;
      if (p > max) max = p;
      if (p >= 0.5) high++;
    }
    return (avg: sum / edges.length, max: max, high: high, n: edges.length);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<DisasterMapData>(
      future: _mapFut,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final map = snap.data!;
        if (!_primed) {
          _primed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.read<RouteRiskController>().recompute(map);
          });
        }

        return Consumer<RouteRiskController>(
          builder: (context, risk, _) {
            final stats = _stats(map, risk);
            final sorted = _visibleEdges(map).toList()
              ..sort(
                (a, b) =>
                    risk.riskForEdge(b.id).compareTo(risk.riskForEdge(a.id)),
              );

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: UiTokens.pageInsets.copyWith(bottom: 8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      DdPageIntro(
                        title: 'Road & corridor risk (on-device ML)',
                        description:
                            'Every segment is colored by predicted impassability. '
                            'Use the legend and list to spot worst legs before you plan a route. '
                            'Tap the map or a row for details.',
                      ),
                      if (risk.loadError != null) ...[
                        const SizedBox(height: 10),
                        Material(
                          color: cs.errorContainer.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline_rounded, color: cs.error, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'ONNX model not loaded (${risk.loadError}). '
                                    'Showing rainfall/heuristic risk so levels and % still update.',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      height: 1.35,
                                      color: cs.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _SummaryRow(cs: cs, stats: stats),
                      const SizedBox(height: 12),
                      _LegendBar(),
                      const SizedBox(height: 8),
                      Text(
                        '0% = passable · 100% = likely impassable soon',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All modes'),
                            selected: _modeFilter == 'all',
                            onSelected: (_) =>
                                setState(() => _modeFilter = 'all'),
                          ),
                          ChoiceChip(
                            label: const Text('Road'),
                            selected: _modeFilter == 'road',
                            onSelected: (_) =>
                                setState(() => _modeFilter = 'road'),
                          ),
                          ChoiceChip(
                            label: const Text('River'),
                            selected: _modeFilter == 'river',
                            onSelected: (_) =>
                                setState(() => _modeFilter = 'river'),
                          ),
                          ChoiceChip(
                            label: const Text('Air'),
                            selected: _modeFilter == 'air',
                            onSelected: (_) =>
                                setState(() => _modeFilter = 'air'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _WeatherCard(
                        risk: risk,
                        onChanged: () => _onInputsChanged(map, risk),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const FullRoutePlannerPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.alt_route_rounded),
                        label: const Text('Plan route with these risk weights'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Live map',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 360,
                      child: FlutterMap(
                        mapController: _mapCtl,
                        options: MapOptions(
                          initialCenter: map.center,
                          initialZoom: 8.35,
                          minZoom: 5,
                          maxZoom: 14,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                          onTap: (tapPosition, latlng) {
                            final (edge, dMeters) = nearestEdgeToTap(
                              map,
                              latlng,
                              edges: _visibleEdges(map),
                            );
                            if (edge == null || dMeters > 20000) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Tap closer to a colored segment.',
                                  ),
                                ),
                              );
                              return;
                            }
                            showEdgeRiskDetailDialog(context, map, edge, risk);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'digital_delta_app',
                          ),
                          PolylineLayer(
                            polylines: [
                              for (final e in _visibleEdges(map))
                                if (map.nodeLatLng[e.from] != null &&
                                    map.nodeLatLng[e.to] != null)
                                  Polyline(
                                    points: [
                                      map.nodeLatLng[e.from]!,
                                      map.nodeLatLng[e.to]!,
                                    ],
                                    color: riskPolylineColor(
                                      edge: e,
                                      map: map,
                                      risk01: risk.riskForEdge(e.id),
                                    ),
                                    strokeWidth:
                                        2.5 + risk.riskForEdge(e.id) * 5,
                                  ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              for (final n in map.nodes)
                                Marker(
                                  width: 72,
                                  height: 36,
                                  point: n.latLng,
                                  alignment: Alignment.bottomCenter,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.place_rounded,
                                        color: cs.primary,
                                        size: 22,
                                      ),
                                      Text(
                                        n.id,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: UiTokens.pageInsets.copyWith(top: 12, bottom: 28),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Segments by risk (highest first)',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        );
                      }
                      final e = sorted[i - 1];
                      final p = risk.riskForEdge(e.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () =>
                                showEdgeRiskDetailDialog(context, map, e, risk),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: riskHeatColor(p),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${e.id} · ${e.mode} · ${e.from}→${e.to}',
                                          style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'LEVEL',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.6,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                          Text(
                                            riskBandLabel(p),
                                            style: GoogleFonts.dmSans(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18,
                                              color: riskHeatColor(p),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'RISK',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.6,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                          Text(
                                            '${(p * 100).toStringAsFixed(0)}%',
                                            style: GoogleFonts.dmSans(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 26,
                                              height: 1.0,
                                              color: riskHeatColor(p),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${e.baseWeightMins.toStringAsFixed(0)} min base travel',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: p.clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: cs.surfaceContainerHigh,
                                      color: riskHeatColor(p),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }, childCount: sorted.length + 1),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.cs, required this.stats});

  final ColorScheme cs;
  final ({double avg, double max, int high, int n}) stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StatPill(
            cs: cs,
            label: 'Mean risk',
            value: stats.n == 0 ? '—' : '${(stats.avg * 100).round()}%',
            subtitle: stats.n == 0 ? null : riskBandLabel(stats.avg),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatPill(
            cs: cs,
            label: 'Worst leg',
            value: stats.n == 0 ? '—' : '${(stats.max * 100).round()}%',
            subtitle: stats.n == 0 ? null : riskBandLabel(stats.max),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatPill(
            cs: cs,
            label: '≥50% legs',
            value: stats.n == 0 ? '—' : '${stats.high}/${stats.n}',
            subtitle: stats.n == 0 ? null : 'of visible',
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.cs,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final ColorScheme cs;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 10, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              height: 1.1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risk scale (impassability probability)',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Container(
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF16A34A),
                Color(0xFFEAB308),
                Color(0xFFEA580C),
                Color(0xFFDC2626),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0%',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
            Text(
              '100%',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.risk, required this.onChanged});

  final RouteRiskController risk;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          'Weather & terrain inputs',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          'Adjust to match spotter reports — all segments recompute',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Rain (mm/h): ${risk.rainMmPerH.toStringAsFixed(1)}'),
                Slider(
                  value: risk.rainMmPerH.clamp(0, 80),
                  min: 0,
                  max: 80,
                  divisions: 40,
                  onChanged: (v) {
                    risk.rainMmPerH = v;
                    onChanged();
                  },
                ),
                Text(
                  'Storm duration (h): ${risk.stormHours.toStringAsFixed(1)}',
                ),
                Slider(
                  value: risk.stormHours.clamp(0.5, 24),
                  min: 0.5,
                  max: 24,
                  divisions: 47,
                  onChanged: (v) {
                    risk.stormHours = v;
                    onChanged();
                  },
                ),
                Text(
                  'Elevation proxy (m): ${risk.elevationM.toStringAsFixed(0)}',
                ),
                Slider(
                  value: risk.elevationM.clamp(0, 200),
                  min: 0,
                  max: 200,
                  divisions: 40,
                  onChanged: (v) {
                    risk.elevationM = v;
                    onChanged();
                  },
                ),
                Text(
                  'Soil saturation: ${risk.soilSaturation.toStringAsFixed(2)}',
                ),
                Slider(
                  value: risk.soilSaturation.clamp(0, 1),
                  min: 0,
                  max: 1,
                  divisions: 20,
                  onChanged: (v) {
                    risk.soilSaturation = v;
                    onChanged();
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Apply ML in route planner'),
                  subtitle: const Text(
                    'Turn off to compare static graph weights only',
                  ),
                  value: risk.useMlInRouting,
                  onChanged: (v) {
                    risk.setUseMlInRouting(v);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
