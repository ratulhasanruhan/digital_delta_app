import 'dart:convert';

/// How two vector clocks relate (M2.2 causal ordering).
enum CausalRelation { before, after, concurrent, equivalent }

/// Per-replica Lamport-style counters (aligns with `proto/digitaldelta/v1/common.proto` VectorClock).
class VectorClock {
  VectorClock([Map<String, int>? components])
      : _c = Map<String, int>.from(components ?? {});

  final Map<String, int> _c;

  Map<String, int> get components => Map.unmodifiable(_c);

  /// Increment this replica's entry (call after each local mutation).
  VectorClock tick(String replicaId) {
    final next = Map<String, int>.from(_c);
    next[replicaId] = (next[replicaId] ?? 0) + 1;
    return VectorClock(next);
  }

  /// Pointwise max — used when merging remote state.
  VectorClock merge(VectorClock other) {
    final out = Map<String, int>.from(_c);
    for (final e in other._c.entries) {
      out[e.key] = (out[e.key] ?? 0) < e.value ? e.value : out[e.key]!;
    }
    return VectorClock(out);
  }

  /// True if this clock is ≥ [other] at every replica (classic vector-clock partial order).
  bool dominates(VectorClock other) {
    final keys = {..._c.keys, ...other._c.keys};
    for (final k in keys) {
      final a = _c[k] ?? 0;
      final b = other._c[k] ?? 0;
      if (a < b) return false;
    }
    return true;
  }

  /// Causal relation for M2.2 demos (A vs B).
  CausalRelation causalCompare(VectorClock other) {
    final aDom = dominates(other);
    final bDom = other.dominates(this);
    if (aDom && bDom) return CausalRelation.equivalent;
    if (aDom) return CausalRelation.after;
    if (bDom) return CausalRelation.before;
    return CausalRelation.concurrent;
  }

  String toJsonString() => jsonEncode(_c);

  static VectorClock fromJsonString(String? s) {
    if (s == null || s.isEmpty) return VectorClock();
    final decoded = jsonDecode(s);
    if (decoded is! Map<String, dynamic>) return VectorClock();
    return VectorClock(
      decoded.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }

  @override
  String toString() => _c.toString();

  @override
  bool operator ==(Object other) =>
      other is VectorClock && _mapEquals(_c, other._c);

  @override
  int get hashCode => Object.hashAll(_c.entries);

  static bool _mapEquals(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (a[k] != b[k]) return false;
    }
    return true;
  }
}
