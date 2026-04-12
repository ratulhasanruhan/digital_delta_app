import 'vector_clock.dart';

/// M2.3 — concurrent edit on the same logical field (demo LWW fork).
class CrdtConflict {
  CrdtConflict({
    required this.id,
    required this.elementId,
    required this.uniqueTag,
    required this.fieldName,
    required this.leftValue,
    required this.rightValue,
    required this.leftClock,
    required this.rightClock,
    required this.status,
    this.resolvedValue,
    this.resolvedAtMs,
  });

  final String id;
  final String elementId;
  final String uniqueTag;
  final String fieldName;
  final String leftValue;
  final String rightValue;
  final VectorClock leftClock;
  final VectorClock rightClock;
  final String status;
  final String? resolvedValue;
  final int? resolvedAtMs;

  bool get isPending => status == 'pending';
}
