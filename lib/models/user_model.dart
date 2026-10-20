enum UserRole {
  warga,
  operator,
  pengawas,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.warga:
        return 'Warga';
      case UserRole.operator:
        return 'Operator';
      case UserRole.pengawas:
        return 'Pengawas RW';
    }
  }

  String get roleBadge {
    switch (this) {
      case UserRole.warga:
        return 'Penyetor Sampah';
      case UserRole.operator:
        return 'Operator Biodigester';
      case UserRole.pengawas:
        return 'Ketua RW 05';
    }
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String rw;
  final String rt;
  int points;
  double monthlyTargetKg;
  double currentMonthKg;
  int monthlySubmissionsCount;
  int monthlyClaimsCount;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.rw,
    required this.rt,
    this.points = 0,
    this.monthlyTargetKg = 25.0,
    this.currentMonthKg = 0.0,
    this.monthlySubmissionsCount = 0,
    this.monthlyClaimsCount = 0,
  });
}
