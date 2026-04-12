import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app/ui_tokens.dart';
import '../data/disaster_map_loader.dart';
import '../domain/vehicle_profile.dart';
import '../ml/edge_risk_onnx.dart' show EdgeRiskOnnx, edgeIdNorm;
import '../routing/simple_route_planner.dart';

/// M4 + M7 — multi-modal graph, vehicle constraints, edge closure, ONNX risk, replan timing.
class InteractiveMapPage extends StatefulWidget {
  const InteractiveMapPage({super.key});

  @override
  State<InteractiveMapPage> createState() => _InteractiveMapPageState();
}

class _InteractiveMapPageState extends State<InteractiveMapPage> {
  late Future<DisasterMapData> _mapFuture;
  final MapController _map = MapController();
  final EdgeRiskOnnx _onnx = EdgeRiskOnnx();
  final LayerHitNotifier<String> _edgeHitNotifier = LayerHitNotifier<String>(null);

  DisasterMapData? _mapDataCache;

  VehicleKind _vehicle = VehicleKind.truck;
  String? _fromId;
  String? _toId;
  List<String>? _pathNodes;
  double? _pathMins;
  int? _replanMs;
  double _rainMm = 12;
  double _cumHours = 3;
  double _elev = 35;
  double _soil = 0.35;
  String? _riskEdgeId;
  Map<String, double> _onnxByEdge = {};
  bool _onnxReady = false;
  DateTime _lastOnnxEvalAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _mapFuture = DisasterMapData.load();
    _edgeHitNotifier.addListener(_onEdgePolylineHit);
    _bootstrapMap();
  }

  void _onEdgePolylineHit() {
    final v = _edgeHitNotifier.value;
    final data = _mapDataCache;
    if (!mounted || v == null || v.hitValues.isEmpty || data == null) {
      return;
    }
    final edgeId = v.hitValues.first;
    _showEdgeRiskSheet(context, data, edgeId);
  }

  Future<void> _bootstrapMap() async {
    final data = await _mapFuture;
    try {
      await _onnx.load();
      if (mounted) setState(() => _onnxReady = true);
    } catch (_) {
      if (mounted) setState(() => _onnxReady = false);
    }
    if (!mounted) return;
    if (data.nodes.length >= 2) {
      setState(() {
        _fromId = data.nodes.first.id;
        _toId = data.nodes.last.id;
        if (data.typedEdges.isNotEmpty) {
          _riskEdgeId = data.typedEdges.first.id;
        }
      });
    }
    _recomputeOnnx(data);
    _planRoute(data);
  }

  @override
  void dispose() {
    _edgeHitNotifier.removeListener(_onEdgePolylineHit);
    _onnx.dispose();
    super.dispose();
  }

  void _showEdgeRiskSheet(BuildContext context, DisasterMapData data, String edgeId) {
    final p = _onnxByEdge[edgeId] ?? 0;
    final cum = _rainMm * _cumHours;
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edge $edgeId — M7 risk', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'P(impassable soon) ≈ ${p.toStringAsFixed(3)}',
                style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(color: cs.primary),
              ),
              const SizedBox(height: 12),
              Text('Features used', style: Theme.of(ctx).textTheme.labelLarge),
              Text('cumulative_rain_mm: ${cum.toStringAsFixed(1)}'),
              Text('rain_rate_mm_per_h: ${_rainMm.toStringAsFixed(1)}'),
              Text('elevation_m: ${_elev.toStringAsFixed(0)}'),
              Text('soil_saturation_proxy: ${_soil.toStringAsFixed(2)}'),
              Text('edge_id_hash_norm: ${edgeIdNorm(edgeId).toStringAsFixed(4)}'),
              const SizedBox(height: 8),
              Text(
                'Prediction time: ${_lastOnnxEvalAt.toLocal().toIso8601String()}',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: adjust rain sliders in the panel — map tint and this score update together; routing uses the same penalty.',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
              ),
            ],
          ),
        );
      },
    );
  }

  void _recomputeOnnx(DisasterMapData data) {
    if (!_onnx.isLoaded) return;
    final m = <String, double>{};
    for (final e in data.typedEdges) {
      final cum = _rainMm * _cumHours;
      try {
        m[e.id] = _onnx.predict(
          cumulativeRainMm: cum,
          rainRateMmPerH: _rainMm,
          elevationM: _elev,
          soilSaturationProxy: _soil,
          edgeIdHashNorm: edgeIdNorm(e.id),
        );
      } catch (_) {
        m[e.id] = 0;
      }
    }
    setState(() {
      _onnxByEdge = m;
      _lastOnnxEvalAt = DateTime.now();
    });
  }

  void _planRoute(DisasterMapData data) {
    if (_fromId == null || _toId == null || _fromId == _toId) {
      setState(() {
        _pathNodes = null;
        _pathMins = null;
        _replanMs = null;
      });
      return;
    }
    final sw = Stopwatch()..start();
    final g = data.graphForVehicle(
      vehicle: _vehicle,
      onnxRiskByEdgeId: _onnxByEdge,
    );
    final r = shortestPathMinutes(
      graph: g,
      startId: _fromId!,
      goalId: _toId!,
    );
    sw.stop();
    setState(() {
      _pathNodes = r?.nodeIds;
      _pathMins = r?.totalMinutes;
      _replanMs = sw.elapsedMilliseconds;
    });
    if (r != null && r.nodeIds.length >= 2) {
      final pts = r.nodeIds
          .map((id) => data.nodeLatLng[id])
          .whereType<LatLng>()
          .toList();
      if (pts.length >= 2) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _map.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(pts),
              padding: const EdgeInsets.all(48),
            ),
          );
        });
      }
    }
  }

  Color _edgeColor(String mode) {
    return switch (mode) {
      'road' => Colors.indigo.withValues(alpha: 0.55),
      'river' => Colors.teal.withValues(alpha: 0.55),
      'air' => Colors.deepPurple.withValues(alpha: 0.6),
      _ => Colors.blueGrey.withValues(alpha: 0.45),
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<DisasterMapData>(
      future: _mapFuture,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Map: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snap.data!;
        _mapDataCache = data;
        if (_riskEdgeId == null && data.typedEdges.isNotEmpty) {
          _riskEdgeId = data.typedEdges.first.id;
        }

        return Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCenter: data.center,
                  initialZoom: 8.2,
                  minZoom: 5,
                  maxZoom: 18,
                  onTap: (_, __) => FocusScope.of(context).unfocus(),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'digital_delta_app',
                  ),
                  PolylineLayer(
                    polylines: [
                      for (final e in data.typedEdges)
                        if (data.nodeLatLng[e.from] != null &&
                            data.nodeLatLng[e.to] != null)
                          Polyline(
                            points: [
                              data.nodeLatLng[e.from]!,
                              data.nodeLatLng[e.to]!,
                            ],
                            strokeWidth: data.closedEdgeIds.contains(e.id) ? 1 : 2,
                            color: data.closedEdgeIds.contains(e.id)
                                ? Colors.grey.withValues(alpha: 0.35)
                                : _edgeColor(e.mode).withValues(
                                    alpha: 0.35 +
                                        0.4 * (_onnxByEdge[e.id] ?? 0),
                                  ),
                          ),
                    ],
                  ),
                  if (_pathNodes != null && _pathNodes!.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _pathNodes!
                              .map((id) => data.nodeLatLng[id])
                              .whereType<LatLng>()
                              .toList(),
                          strokeWidth: 5,
                          color: cs.primary,
                        ),
                      ],
                    ),
                  PolylineLayer<String>(
                    hitNotifier: _edgeHitNotifier,
                    minimumHitbox: 14,
                    polylines: [
                      for (final e in data.typedEdges)
                        if (data.nodeLatLng[e.from] != null &&
                            data.nodeLatLng[e.to] != null)
                          Polyline<String>(
                            points: [
                              data.nodeLatLng[e.from]!,
                              data.nodeLatLng[e.to]!,
                            ],
                            strokeWidth: 24,
                            color: const Color(0x01FFFFFF),
                            hitValue: e.id,
                          ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      for (final n in data.nodes)
                        Marker(
                          point: n.latLng,
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.place_rounded,
                            color: _pathNodes?.contains(n.id) == true
                                ? cs.primary
                                : Colors.deepOrange,
                            size: 38,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Material(
              elevation: 6,
              shadowColor: cs.shadow.withValues(alpha: 0.12),
              color: cs.surfaceContainerHigh,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(UiTokens.pageH, 14, UiTokens.pageH, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Routes & conditions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pick vehicle, from/to, and optional edge closures. Rain overlay tints legs by flood risk. '
                        'Tap a line on the map for M7 probability + features (M7.4).',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<VehicleKind>(
                        segments: const [
                          ButtonSegment(
                            value: VehicleKind.truck,
                            label: Text('Truck'),
                            icon: Icon(Icons.local_shipping_outlined),
                          ),
                          ButtonSegment(
                            value: VehicleKind.speedboat,
                            label: Text('Boat'),
                            icon: Icon(Icons.sailing_outlined),
                          ),
                          ButtonSegment(
                            value: VehicleKind.drone,
                            label: Text('Drone'),
                            icon: Icon(Icons.flight_outlined),
                          ),
                        ],
                        selected: {_vehicle},
                        onSelectionChanged: (s) {
                          setState(() => _vehicle = s.first);
                          _planRoute(data);
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Payload limit: ${_vehicle.maxPayloadKg.toStringAsFixed(0)} kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final e in data.typedEdges.take(8))
                            FilterChip(
                              label: Text('${e.id} close'),
                              selected: data.closedEdgeIds.contains(e.id),
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    data.closedEdgeIds.add(e.id);
                                  } else {
                                    data.closedEdgeIds.remove(e.id);
                                  }
                                });
                                _planRoute(data);
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'M7 features — penalize edges (ONNX ${_onnxReady ? "ON" : "off"})',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text('Rain mm/h: ${_rainMm.toStringAsFixed(0)}'),
                      Slider(
                        value: _rainMm,
                        max: 120,
                        divisions: 24,
                        onChanged: (v) => setState(() => _rainMm = v),
                        onChangeEnd: (_) {
                          _recomputeOnnx(data);
                          _planRoute(data);
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'From',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              value: _fromId,
                              items: [
                                for (final n in data.nodes)
                                  DropdownMenuItem(value: n.id, child: Text(n.id)),
                              ],
                              onChanged: (v) {
                                setState(() => _fromId = v);
                                _planRoute(data);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'To',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              value: _toId,
                              items: [
                                for (final n in data.nodes)
                                  DropdownMenuItem(value: n.id, child: Text(n.id)),
                              ],
                              onChanged: (v) {
                                setState(() => _toId = v);
                                _planRoute(data);
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_pathMins != null)
                        Text(
                          'Route: ${_pathNodes?.join(" → ") ?? ""} · '
                          '${_pathMins!.toStringAsFixed(0)} min effective · '
                          'replan ${_replanMs ?? 0} ms',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        )
                      else
                        Text(
                          _fromId != null && _toId != null
                              ? 'No path for ${_vehicle.label} — try another mode or open edges.'
                              : 'Select endpoints.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (_riskEdgeId != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Edge ${_riskEdgeId!}: P(impass) = ${(_onnxByEdge[_riskEdgeId!] ?? 0).toStringAsFixed(3)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
