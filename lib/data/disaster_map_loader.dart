import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';

import '../domain/vehicle_profile.dart';
import '../routing/simple_route_planner.dart';
import '../routing/typed_route_planner.dart';

/// Sylhet graph for M4 / M6 / M8 with road, river, and air edges.
class DisasterMapData {
  DisasterMapData({
    required this.metadata,
    required this.nodeLatLng,
    required this.nodes,
    required this.typedEdges,
  });

  final Map<String, dynamic> metadata;
  final Map<String, LatLng> nodeLatLng;
  final List<MapNode> nodes;
  final List<TypedEdge> typedEdges;

  /// Runtime closure (washed out / impassable) — edge ids.
  final Set<String> closedEdgeIds = {};

  LatLng get center {
    if (nodes.isEmpty) return const LatLng(24.89, 91.87);
    var sLat = 0.0;
    var sLng = 0.0;
    for (final n in nodes) {
      sLat += n.latLng.latitude;
      sLng += n.latLng.longitude;
    }
    return LatLng(sLat / nodes.length, sLng / nodes.length);
  }

  TypedEdge? edgeById(String id) {
    try {
      return typedEdges.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// M4 + M7 — optional ONNX impassability per edge id [0–1].
  RouteGraph graphForVehicle({
    required VehicleKind vehicle,
    Map<String, double> onnxRiskByEdgeId = const {},
  }) {
    return buildRouteGraph(
      edges: typedEdges,
      include: (e) {
        if (closedEdgeIds.contains(e.id)) return false;
        return vehicle.canUseEdgeMode(e.mode);
      },
      weightForEdge: (e) {
        final onnx = onnxRiskByEdgeId[e.id] ?? 0;
        return e.effectiveMinutes(onnxImpassabilityProb: onnx);
      },
    );
  }

  /// All modes (for admin / debug).
  RouteGraph graphAllModes({Map<String, double> onnxRiskByEdgeId = const {}}) {
    return buildRouteGraph(
      edges: typedEdges,
      include: (e) => !closedEdgeIds.contains(e.id),
      weightForEdge: (e) {
        final onnx = onnxRiskByEdgeId[e.id] ?? 0;
        return e.effectiveMinutes(onnxImpassabilityProb: onnx);
      },
    );
  }

  static Future<DisasterMapData> load() async {
    final raw = await rootBundle.loadString('assets/data/sylhet_map.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final meta = (json['metadata'] as Map<String, dynamic>?) ?? {};
    final rawNodes = json['nodes'] as List<dynamic>? ?? [];
    final rawEdges = json['edges'] as List<dynamic>? ?? [];

    final nodeLatLng = <String, LatLng>{};
    final nodes = <MapNode>[];
    for (final n in rawNodes) {
      if (n is! Map<String, dynamic>) continue;
      final id = n['id']?.toString() ?? '';
      final lat = (n['lat'] as num?)?.toDouble();
      final lng = (n['lng'] as num?)?.toDouble();
      if (id.isEmpty || lat == null || lng == null) continue;
      final ll = LatLng(lat, lng);
      nodeLatLng[id] = ll;
      nodes.add(
        MapNode(
          id: id,
          name: n['name']?.toString() ?? id,
          type: n['type']?.toString() ?? '—',
          latLng: ll,
        ),
      );
    }

    final typedEdges = <TypedEdge>[];
    for (final e in rawEdges) {
      if (e is! Map<String, dynamic>) continue;
      final id = e['id']?.toString() ?? '';
      final s = e['source']?.toString();
      final t = e['target']?.toString();
      final w = (e['base_weight_mins'] as num?)?.toDouble();
      if (id.isEmpty || s == null || t == null || w == null) continue;
      if (!nodeLatLng.containsKey(s) || !nodeLatLng.containsKey(t)) continue;
      final type = e['type']?.toString() ?? 'road';
      final risk = (e['risk_score'] as num?)?.toDouble() ?? 0.25;
      final cap = (e['capacity_kg'] as num?)?.toDouble() ?? 10000;
      typedEdges.add(
        TypedEdge(
          id: id,
          from: s,
          to: t,
          mode: type,
          baseWeightMins: w,
          riskScore: risk.clamp(0.0, 1.0),
          capacityKg: cap,
          isFlooded: e['is_flooded'] == true,
        ),
      );
    }

    return DisasterMapData(
      metadata: meta,
      nodeLatLng: nodeLatLng,
      nodes: nodes,
      typedEdges: typedEdges,
    );
  }
}

class MapNode {
  const MapNode({
    required this.id,
    required this.name,
    required this.type,
    required this.latLng,
  });

  final String id;
  final String name;
  final String type;
  final LatLng latLng;
}
