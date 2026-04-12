/// Cargo tier (maps to `CargoPriority` in proto).
enum CargoPriority {
  p0(1, 'P0 critical'),
  p1(2, 'P1 high'),
  p2(3, 'P2 standard'),
  p3(4, 'P3 low');

  const CargoPriority(this.protoValue, this.label);
  final int protoValue;
  final String label;

  static CargoPriority fromInt(int v) {
    return CargoPriority.values.firstWhere(
      (e) => e.protoValue == v,
      orElse: () => CargoPriority.p2,
    );
  }
}

/// One OR-Set element (visible supply line).
class SupplyLine {
  const SupplyLine({
    required this.elementId,
    required this.uniqueTag,
    required this.sku,
    required this.description,
    required this.quantity,
    required this.priority,
    required this.locationNodeId,
  });

  final String elementId;
  final String uniqueTag;
  final String sku;
  final String description;
  final int quantity;
  final CargoPriority priority;
  final String locationNodeId;
}
