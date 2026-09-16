/// Mirrors a document in /parents/{uid}.
/// A parent account can be linked to more than one student.
class ParentProfile {
  final String uid;
  final List<String> studentIds;
  final String? phone;
  final String? address;

  const ParentProfile({
    required this.uid,
    required this.studentIds,
    this.phone,
    this.address,
  });

  factory ParentProfile.fromMap(String uid, Map<String, dynamic> map) {
    return ParentProfile(
      uid: uid,
      studentIds: List<String>.from(map['studentIds'] as List? ?? const []),
      phone: map['phone'] as String?,
      address: map['address'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentIds': studentIds,
      'phone': phone,
      'address': address,
    };
  }
}
