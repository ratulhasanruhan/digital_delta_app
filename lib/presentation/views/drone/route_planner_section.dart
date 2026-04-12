import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../app/app_theme.dart';
import '../../../app/ui_tokens.dart';
import '../../../data/disaster_map_loader.dart';
import '../../../domain/vehicle_profile.dart';
import '../../../features/risk/edge_risk_dialog.dart';
import '../../../features/risk/risk_map_utils.dart';
import '../../../features/risk/route_risk_controller.dart';
import '../../../routing/multi_modal_planner.dart';
import '../../../routing/simple_route_planner.dart';
import '../../../widgets/dd_page_intro.dart';

/// M4 — multi-modal graph, Dijkstra, dynamic closures, live map (OSM tiles).
class RoutePlannerSection extends StatefulWidget {
  const RoutePlannerSection({super.key});

  @override
  State<RoutePlannerSection> createState() => _RoutePlannerSectionState();
}

class _RoutePlannerSectionState extends State<RoutePlannerSection> {
  Future<DisasterMapData>? _mapFut;
  String _startId = 'N1';
  String _goalId = 'N6';
  VehicleKind _vehicle = VehicleKind.truck;
  bool _multiModal = true;
  double _payloadKg = 800;
  PathResult? _singlePath;
  MultiModalPathResult? _multiPath;
  int? _lastComputeMs;
  final MapController _mapCtl = MapController();

  @override
  void initState() {
    super.initState();
    _mapFut = DisasterMapData.load();
    unawaited(
      _mapFut!.then((map) {
        if (!mounted) return;
        context.read<RouteRiskController>().recompute(map);
      }),
    );
  }

  Future<void> _compute(DisasterMapData map) async {
    final sw = Stopwatch()..start();
    final risk = context.read<RouteRiskController>();
    final onnx = risk.onnxRiskByEdgeId;
    try {
      if (_multiModal) {
        final r = shortestMultiModalPath(
          map: map,
          startId: _startId,
          goalId: _goalId,
          startVehicle: _vehicle,
          payloadKg: _payloadKg,
          onnxRiskByEdgeId: onnx,
        );
        sw.stop();
        setState(() {
          _multiPath = r;
          _singlePath = null;
          _lastComputeMs = sw.elapsedMilliseconds;
        });
      } else {
        final g = map.graphForVehicle(
          vehicle: _vehicle,
          onnxRiskByEdgeId: onnx,
        );
        final r = shortestPathMinutes(
          graph: g,
          startId: _startId,
          goalId: _goalId,
        );
        sw.stop();
        setState(() {
          _singlePath = r;
          _multiPath = null;
          _lastComputeMs = sw.elapsedMilliseconds;
        });
      }
      _fitMap(map);
    } catch (e) {
      sw.stop();
      setState(() {
        _lastComputeMs = sw.elapsedMilliseconds;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  void _fitMap(DisasterMapData map) {
    final pts = <LatLng>[];
    if (_multiPath != null) {
      for (final s in _multiPath!.segments) {
        for (final id in s.nodeIds) {
          final ll = map.nodeLatLng[id];
          if (ll != null) pts.add(ll);
        }
      }
    } else if (_singlePath != null) {
      for (final id in _singlePath!.nodeIds) {
        final ll = map.nodeLatLng[id];
        if (ll != null) pts.add(ll);
      }
    }
    if (pts.length < 2) return;
    final bounds = LatLngBounds.fromPoints(pts);
    unawaited(
      Future<void>(() async {
        await Future<void>.delayed(const Duration(milliseconds: 80));
        if (!mounted) return;
        _mapCtl.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
        );
      }),
    );
  }

  Widget _locationField({
    required String value,
    required String label,
    required ValueChanged<String?> onChanged,
    required List<DropdownMenuItem<String>> items,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DisasterMapData>(
      future: _mapFut,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final map = snap.data!;

        return Consumer<RouteRiskController>(
          builder: (context, risk, _) {
            final cs = Theme.of(context).colorScheme;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DdPageIntro(
                  title: 'Routes & hazards (M4)',
                  description:
                      'Road, river, and air links use travel time × static risk, with optional ONNX flood risk applied in routing. '
                      'Tap a segment for probability and features.',
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 300,
                    child: FlutterMap(
                      mapController: _mapCtl,
                      options: MapOptions(
                        initialCenter: map.center,
                        initialZoom: 8.2,
                        minZoom: 5,
                        maxZoom: 14,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                        onTap: (tapPosition, latlng) {
                          final (edge, dMeters) = nearestEdgeToTap(map, latlng);
                          if (edge == null || dMeters > 18000) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tap closer to a route segment.'),
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
                            for (final e in map.typedEdges)
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
                                  strokeWidth: map.closedEdgeIds.contains(e.id)
                                      ? 1
                                      : 3,
                                ),
                          ],
                        ),
                        PolylineLayer(
                          polylines: [
                            if (_multiPath != null)
                              for (final seg in _multiPath!.segments)
                                if (seg.nodeIds.length >= 2)
                                  Polyline(
                                    points: [
                                      for (final id in seg.nodeIds)
                                        if (map.nodeLatLng[id] != null)
                                          map.nodeLatLng[id]!,
                                    ],
                                    color: cs.primary,
                                    strokeWidth: 5,
                                  ),
                            if (_multiPath == null &&
                                _singlePath != null &&
                                _singlePath!.nodeIds.length >= 2)
                              Polyline(
                                points: [
                                  for (final id in _singlePath!.nodeIds)
                                    if (map.nodeLatLng[id] != null)
                                      map.nodeLatLng[id]!,
                                ],
                                color: cs.primary,
                                strokeWidth: 5,
                              ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            for (final n in map.nodes)
                              Marker(
                                width: 88,
                                height: 40,
                                point: n.latLng,
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.place_rounded,
                                      color: cs.primary,
                                      size: 26,
                                    ),
                                    Text(
                                      n.id,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 9,
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
                const SizedBox(height: 8),
                Text(
                  'OpenStreetMap tiles (cacheable for offline in production builds).',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Text(
                  'Plan delivery',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 520;
                    final dropdowns = [
                      _locationField(
                        value: _startId,
                        label: 'From',
                        items: [
                          for (final n in map.nodes)
                            DropdownMenuItem(
                              value: n.id,
                              child: Text(
                                '${n.name} (${n.id})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (v) =>
                            setState(() => _startId = v ?? _startId),
                      ),
                      _locationField(
                        value: _goalId,
                        label: 'To',
                        items: [
                          for (final n in map.nodes)
                            DropdownMenuItem(
                              value: n.id,
                              child: Text(
                                '${n.name} (${n.id})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (v) =>
                            setState(() => _goalId = v ?? _goalId),
                      ),
                    ];

                    if (compact) {
                      return Column(
                        children: [
                          dropdowns[0],
                          const SizedBox(height: 10),
                          dropdowns[1],
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: dropdowns[0]),
                        const SizedBox(width: 10),
                        Expanded(child: dropdowns[1]),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<VehicleKind>(
                  initialValue: _vehicle,
                  decoration: const InputDecoration(
                    labelText: 'Starting vehicle',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final v in VehicleKind.values)
                      DropdownMenuItem(value: v, child: Text(v.label)),
                  ],
                  onChanged: (v) => setState(() => _vehicle = v ?? _vehicle),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Allow multi-modal handoffs'),
                  subtitle: const Text('Truck ↔ boat ↔ drone at hubs (M4.3)'),
                  value: _multiModal,
                  onChanged: (v) => setState(() => _multiModal = v),
                ),
                Text(
                  'Payload (kg): ${_payloadKg.round()}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Slider(
                  value: _payloadKg.clamp(50, 12000),
                  min: 50,
                  max: 12000,
                  divisions: 40,
                  label: '${_payloadKg.round()} kg',
                  onChanged: (v) => setState(() => _payloadKg = v),
                ),
                FilledButton.icon(
                  onPressed: () => _compute(map),
                  icon: const Icon(Icons.route_rounded),
                  label: const Text('Compute route'),
                ),
                if (_lastComputeMs != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'M4.2 recompute: ${_lastComputeMs!} ms (target < 2000 ms)',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      color: _lastComputeMs! < 2000
                          ? AppTheme.brandGreen
                          : cs.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Hazard: mark segment washed out',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...map.typedEdges.map((e) {
                  final closed = map.closedEdgeIds.contains(e.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: SwitchListTile(
                      dense: true,
                      title: Text(
                        '${e.id} · ${e.mode} · ${e.from}→${e.to}',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${e.baseWeightMins.toStringAsFixed(0)} min · risk ${e.riskScore.toStringAsFixed(2)}',
                        style: GoogleFonts.dmSans(fontSize: 11),
                      ),
                      value: closed,
                      onChanged: (v) {
                        setState(() {
                          if (v) {
                            map.closedEdgeIds.add(e.id);
                          } else {
                            map.closedEdgeIds.remove(e.id);
                          }
                        });
                        unawaited(_compute(map));
                      },
                    ),
                  );
                }),
                const SizedBox(height: 12),
                if (_multiPath != null) ...[
                  Text(
                    'Result',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Total ≈ ${_multiPath!.totalMinutes.toStringAsFixed(1)} min',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  for (final s in _multiPath!.segments)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${s.vehicle.label}: ${s.nodeIds.join(' → ')} (${s.minutes.toStringAsFixed(1)} min)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  for (final h in _multiPath!.handoffs)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 18,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Handoff @ ${h.nodeName}: ${h.fromVehicle.label} → ${h.toVehicle.label}',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                if (_multiPath == null && _singlePath != null) ...[
                  Text(
                    'Result',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${_vehicle.label}: ${_singlePath!.nodeIds.join(' → ')}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Total ≈ ${_singlePath!.totalMinutes.toStringAsFixed(1)} min',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (_multiPath == null &&
                    _singlePath == null &&
                    _lastComputeMs != null)
                  Text(
                    'No route under current vehicle / closures. Try another vehicle or clear hazards.',
                    style: TextStyle(color: cs.error),
                  ),
                SizedBox(height: UiTokens.sectionGap),
              ],
            );
          },
        );
      },
    );
  }
}
