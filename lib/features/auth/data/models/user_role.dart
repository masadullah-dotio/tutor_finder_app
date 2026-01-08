enum UserRole {
  parent,
  student,
  tutor,
  admin;

  String get toStringValue {
    return toString().split('.').last;
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.toStringValue == value,
      orElse: () => UserRole.student, // Default to student
    );
  }
}
