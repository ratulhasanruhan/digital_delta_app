/// Thrown when [SupplyRepository] mutates without required permission (M1.3 data layer).
class RbacDeniedException implements Exception {
  RbacDeniedException(this.permission);
  final Permission permission;

  @override
  String toString() => 'RbacDeniedException: missing $permission';
}

/// M1.3 — role-based access with explicit read/write/execute bits.
enum UserRole {
  fieldVolunteer,
  supplyManager,
  droneOperator,
  campCommander,
  syncAdmin,
}

enum Permission {
  readSupply,
  writeSupply,
  executeSync,
  manageIdentity,
  manageFleet,
  triageOverride,
}

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.fieldVolunteer => 'Field Volunteer',
        UserRole.supplyManager => 'Supply Manager',
        UserRole.droneOperator => 'Drone Operator',
        UserRole.campCommander => 'Camp Commander',
        UserRole.syncAdmin => 'Sync Admin',
      };

  Set<Permission> get permissions => switch (this) {
        UserRole.fieldVolunteer => {
            Permission.readSupply,
          },
        UserRole.supplyManager => {
            Permission.readSupply,
            Permission.writeSupply,
          },
        UserRole.droneOperator => {
            Permission.readSupply,
            Permission.writeSupply,
            Permission.manageFleet,
          },
        UserRole.campCommander => {
            Permission.readSupply,
            Permission.writeSupply,
            Permission.triageOverride,
          },
        UserRole.syncAdmin => {
            Permission.readSupply,
            Permission.writeSupply,
            Permission.executeSync,
            Permission.manageIdentity,
            Permission.manageFleet,
            Permission.triageOverride,
          },
      };

  bool can(Permission p) => permissions.contains(p);
}

UserRole userRoleFromStorage(String? raw) {
  if (raw == null || raw.isEmpty) return UserRole.fieldVolunteer;
  return UserRole.values.firstWhere(
    (e) => e.name == raw,
    orElse: () => UserRole.fieldVolunteer,
  );
}
