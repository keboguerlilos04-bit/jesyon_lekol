enum UserRole { admin, teacher, parent, student }

extension UserRoleX on UserRole {
  String get value => name;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.student,
    );
  }
}
