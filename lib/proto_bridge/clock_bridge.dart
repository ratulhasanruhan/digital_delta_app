import 'package:fixnum/fixnum.dart';
import 'package:digital_delta_app/gen/digitaldelta/v1/common.pb.dart' as pb;

import '../crdt/vector_clock.dart' as local;

/// Convert app-level vector clock to protobuf (M2.2).
pb.VectorClock toProtoClock(local.VectorClock vc) {
  final out = pb.VectorClock();
  for (final e in vc.components.entries) {
    out.components.add(
      pb.VectorClockComponent(
        replicaId: e.key,
        counter: Int64(e.value),
      ),
    );
  }
  return out;
}

local.VectorClock fromProtoClock(pb.VectorClock vc) {
  final m = <String, int>{};
  for (final c in vc.components) {
    m[c.replicaId] = c.counter.toInt();
  }
  return local.VectorClock(m);
}

pb.VectorClock mergeProto(pb.VectorClock a, pb.VectorClock b) {
  final keys = <String>{};
  for (final c in a.components) {
    keys.add(c.replicaId);
  }
  for (final c in b.components) {
    keys.add(c.replicaId);
  }
  final out = pb.VectorClock();
  for (final k in keys) {
    var ca = Int64(0);
    var cb = Int64(0);
    for (final c in a.components) {
      if (c.replicaId == k) ca = c.counter;
    }
    for (final c in b.components) {
      if (c.replicaId == k) cb = c.counter;
    }
    final mx = ca > cb ? ca : cb;
    out.components.add(pb.VectorClockComponent(replicaId: k, counter: mx));
  }
  return out;
}
