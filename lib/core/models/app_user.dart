import 'user_role.dart';

/// Mirrors a document in /users/{uid}.
/// The `role` and any id lists (studentIds, classIds) also live in the
/// Firebase Auth custom claims so Firestore Security Rules can read them
/// without an extra document lookup.
class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final bool active;
  /// Free-text job title for staff (e.g. "Sekretè Jeneral", "Pwofesè Matematik").
  /// Purely informational — access control is driven by [role], not this field.
  final String? position;

  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.photoUrl,
    this.active = true,
    this.position,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: UserRoleX.fromString(map['role'] as String? ?? 'student'),
      active: map['active'] as bool? ?? true,
      position: map['position'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role.value,
      'active': active,
      'position': position,
    };
  }
}
