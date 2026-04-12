import 'package:digital_delta_app/gen/digitaldelta/v1/supply.pbenum.dart' as pe;

import '../crdt/supply_models.dart';

int dartPriorityToProtoValue(CargoPriority p) => p.protoValue;

pe.CargoPriority dartPriorityToProto(CargoPriority p) {
  switch (p) {
    case CargoPriority.p0:
      return pe.CargoPriority.CARGO_PRIORITY_P0_CRITICAL_MEDICAL;
    case CargoPriority.p1:
      return pe.CargoPriority.CARGO_PRIORITY_P1_HIGH;
    case CargoPriority.p2:
      return pe.CargoPriority.CARGO_PRIORITY_P2_STANDARD;
    case CargoPriority.p3:
      return pe.CargoPriority.CARGO_PRIORITY_P3_LOW;
  }
}

CargoPriority protoCargoToDart(pe.CargoPriority p) {
  switch (p) {
    case pe.CargoPriority.CARGO_PRIORITY_P0_CRITICAL_MEDICAL:
      return CargoPriority.p0;
    case pe.CargoPriority.CARGO_PRIORITY_P1_HIGH:
      return CargoPriority.p1;
    case pe.CargoPriority.CARGO_PRIORITY_P2_STANDARD:
      return CargoPriority.p2;
    case pe.CargoPriority.CARGO_PRIORITY_P3_LOW:
      return CargoPriority.p3;
    default:
      return CargoPriority.p2;
  }
}

double slaHoursForProto(pe.CargoPriority p) {
  switch (p) {
    case pe.CargoPriority.CARGO_PRIORITY_P0_CRITICAL_MEDICAL:
      return 2;
    case pe.CargoPriority.CARGO_PRIORITY_P1_HIGH:
      return 6;
    case pe.CargoPriority.CARGO_PRIORITY_P2_STANDARD:
      return 24;
    case pe.CargoPriority.CARGO_PRIORITY_P3_LOW:
      return 72;
    default:
      return 24;
  }
}
