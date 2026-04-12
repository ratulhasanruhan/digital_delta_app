import 'package:digital_delta_app/crdt/vector_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tick increments replica', () {
    final a = VectorClock().tick('r1');
    expect(a.components['r1'], 1);
    final b = a.tick('r1');
    expect(b.components['r1'], 2);
  });

  test('merge is pointwise max', () {
    final x = VectorClock({'a': 2, 'b': 1});
    final y = VectorClock({'b': 3, 'c': 1});
    final m = x.merge(y);
    expect(m.components['a'], 2);
    expect(m.components['b'], 3);
    expect(m.components['c'], 1);
  });
}
