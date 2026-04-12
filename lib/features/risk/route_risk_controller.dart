import 'package:flutter/foundation.dart';
import 'package:onnxruntime/onnxruntime.dart';

import '../../data/disaster_map_loader.dart';
import '../../ml/edge_risk_onnx.dart';

/// M7 — shared ONNX risk per edge; feeds M4 routing via [onnxRiskByEdgeId] and map coloring.
class RouteRiskController extends ChangeNotifier {
  RouteRiskController();

  final EdgeRiskOnnx _onnx = EdgeRiskOnnx();

  bool useMlInRouting = true;
  bool isReady = false;
  String? loadError;

  /// Simulated sensor / weather inputs (M7.1 feature engineering).
  double rainMmPerH = 12;
  double stormHours = 3;
  double elevationM = 35;
  double soilSaturation = 0.35;

  final Map<String, double> _riskByEdgeId = {};
  DateTime? lastComputedAt;

  Future<void> init() async {
    try {
      OrtEnv.instance.init();
      await _onnx.load();
      loadError = null;
      isReady = true;
    } catch (e, st) {
      debugPrint('RouteRiskController.init: $e\n$st');
      loadError = '$e';
      isReady = _onnx.isLoaded;
    }
    notifyListeners();
  }

  /// Deterministic fallback when ONNX is unavailable or a single edge fails.
  double _heuristicRisk(String edgeId) {
    final cum = rainMmPerH * stormHours;
    final h = edgeIdNorm(edgeId);
    final wet = (cum / 240).clamp(0.0, 1.0);
    final sat = soilSaturation.clamp(0.0, 1.0);
    final lowland = (1.0 - (elevationM / 200).clamp(0.0, 1.0));
    final raw = wet * 0.42 + sat * 0.28 + lowland * 0.2 + h * 0.1;
    return raw.clamp(0.0, 1.0);
  }

  /// Recomputes impassability probability [0,1] for every edge in [map].
  void recompute(DisasterMapData map) {
    _riskByEdgeId.clear();
    final useOnnx = isReady && _onnx.isLoaded;
    final cum = rainMmPerH * stormHours;
    for (final e in map.typedEdges) {
      if (!useOnnx) {
        _riskByEdgeId[e.id] = _heuristicRisk(e.id);
        continue;
      }
      try {
        final p = _onnx.predict(
          cumulativeRainMm: cum,
          rainRateMmPerH: rainMmPerH,
          elevationM: elevationM,
          soilSaturationProxy: soilSaturation,
          edgeIdHashNorm: edgeIdNorm(e.id),
        );
        _riskByEdgeId[e.id] = p;
      } catch (err) {
        debugPrint('predict ${e.id}: $err');
        _riskByEdgeId[e.id] = _heuristicRisk(e.id);
      }
    }
    lastComputedAt = DateTime.now();
    notifyListeners();
  }

  double riskForEdge(String edgeId) => _riskByEdgeId[edgeId] ?? 0;

  /// Toggles ONNX edge weights in routing without re-running inference.
  void setUseMlInRouting(bool value) {
    useMlInRouting = value;
    notifyListeners();
  }

  /// Passed to [DisasterMapData.graphForVehicle] / [shortestMultiModalPath] (M7.3).
  Map<String, double> get onnxRiskByEdgeId {
    if (!useMlInRouting || _riskByEdgeId.isEmpty) {
      return const {};
    }
    return Map<String, double>.from(_riskByEdgeId);
  }

  @override
  void dispose() {
    _onnx.dispose();
    super.dispose();
  }
}
