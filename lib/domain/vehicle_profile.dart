/// M4.3 — vehicle-specific mode constraints and payload limits (kg).
enum VehicleKind {
  truck,
  speedboat,
  drone,
}

extension VehicleKindX on VehicleKind {
  String get label => switch (this) {
        VehicleKind.truck => 'Truck (roads)',
        VehicleKind.speedboat => 'Speedboat (rivers)',
        VehicleKind.drone => 'Drone (air corridors)',
      };

  /// Max cargo mass this vehicle can carry (demo constants).
  double get maxPayloadKg => switch (this) {
        VehicleKind.truck => 12000,
        VehicleKind.speedboat => 4000,
        VehicleKind.drone => 150,
      };

  bool canUseEdgeMode(String mode) {
    switch (this) {
      case VehicleKind.truck:
        return mode == 'road';
      case VehicleKind.speedboat:
        return mode == 'river';
      case VehicleKind.drone:
        return mode == 'air';
    }
  }
}
