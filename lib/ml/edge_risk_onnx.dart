import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';

/// M7 — loads bundled `edge_risk.onnx` and runs inference matching `ml.proto` feature order.
class EdgeRiskOnnx {
  OrtSession? _session;

  bool get isLoaded => _session != null;

  /// Call once after [OrtEnv.instance.init].
  Future<void> load() async {
    if (_session != null) return;
    try {
      final raw = await rootBundle.load('assets/ml/edge_risk.onnx');
      final opts = OrtSessionOptions()
        ..setIntraOpNumThreads(1)
        ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);
      _session = OrtSession.fromBuffer(raw.buffer.asUint8List(), opts);
      opts.release();
    } catch (e, st) {
      debugPrint('EdgeRiskOnnx.load failed: $e\n$st');
      rethrow;
    }
  }

  void dispose() {
    _session?.release();
    _session = null;
  }

  /// Feature order: cumulative_rain_mm, rain_rate_mm_per_h, elevation_m,
  /// soil_saturation_proxy, edge_id_hash_norm ∈ [0,1].
  double predict({
    required double cumulativeRainMm,
    required double rainRateMmPerH,
    required double elevationM,
    required double soilSaturationProxy,
    required double edgeIdHashNorm,
  }) {
    final s = _session;
    if (s == null) {
      throw StateError('ONNX session not loaded');
    }
    final input = OrtValueTensor.createTensorWithDataList(
      Float32List.fromList([
        cumulativeRainMm,
        rainRateMmPerH,
        elevationM,
        soilSaturationProxy,
        edgeIdHashNorm,
      ]),
      [1, 5],
    );
    final runOpts = OrtRunOptions();
    List<OrtValue?>? outs;
    try {
      outs = s.run(runOpts, {'X': input});
      final tensor = outs[0];
      if (tensor is! OrtValueTensor) {
        throw StateError('unexpected output type');
      }
      final v = tensor.value;
      final p = _firstScalar(v);
      if (p == null) {
        throw StateError('empty ONNX output');
      }
      return p.clamp(0.0, 1.0);
    } finally {
      input.release();
      if (outs != null) {
        for (final o in outs) {
          o?.release();
        }
      }
      runOpts.release();
    }
  }

  double? _firstScalar(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is Float32List && v.isNotEmpty) return v[0].toDouble();
    if (v is List) {
      for (final e in v) {
        final r = _firstScalar(e);
        if (r != null) return r;
      }
    }
    return null;
  }
}

/// Deterministic [0,1] from edge id for the 5th model feature.
double edgeIdNorm(String edgeId) {
  var h = edgeId.hashCode;
  if (h < 0) h = -h;
  return (h % 1000) / 1000.0;
}
