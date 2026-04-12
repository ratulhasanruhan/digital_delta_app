import '../crdt/supply_models.dart';

/// M6.1 — SLA windows aligned with proto / supply bridge.
double slaHoursForCargo(CargoPriority p) {
  switch (p) {
    case CargoPriority.p0:
      return 2;
    case CargoPriority.p1:
      return 6;
    case CargoPriority.p2:
      return 24;
    case CargoPriority.p3:
      return 72;
  }
}

String slaLabel(CargoPriority p) {
  switch (p) {
    case CargoPriority.p0:
      return 'P0 — Critical medical (2h)';
    case CargoPriority.p1:
      return 'P1 — High (6h)';
    case CargoPriority.p2:
      return 'P2 — Standard (24h)';
    case CargoPriority.p3:
      return 'P3 — Low (72h)';
  }
}
