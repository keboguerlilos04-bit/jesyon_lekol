enum EnrollmentStatus { active, pending, withdrawn }

extension EnrollmentStatusX on EnrollmentStatus {
  String get value => name;

  static EnrollmentStatus fromString(String value) {
    return EnrollmentStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => EnrollmentStatus.pending,
    );
  }
}

/// Mirrors a document in /students/{studentId}.
class Student {
  final String id;
  final String? uid; // linked /users/{uid} account, if the student has a login
  final String firstName;
  final String lastName;
  final DateTime? dob;
  final String? sex;
  final String classId;
  final List<String> parentIds;
  final EnrollmentStatus enrollmentStatus;
  final String? photoUrl;

  const Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.classId,
    required this.parentIds,
    this.uid,
    this.dob,
    this.sex,
    this.enrollmentStatus = EnrollmentStatus.pending,
    this.photoUrl,
  });

  String get fullName => '$firstName $lastName';

  factory Student.fromMap(String id, Map<String, dynamic> map) {
    return Student(
      id: id,
      uid: map['uid'] as String?,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      dob: map['dob'] != null ? DateTime.tryParse(map['dob'] as String) : null,
      sex: map['sex'] as String?,
      classId: map['classId'] as String? ?? '',
      parentIds: List<String>.from(map['parentIds'] as List? ?? const []),
      enrollmentStatus: EnrollmentStatusX.fromString(
        map['enrollmentStatus'] as String? ?? 'pending',
      ),
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob?.toIso8601String(),
      'sex': sex,
      'classId': classId,
      'parentIds': parentIds,
      'enrollmentStatus': enrollmentStatus.value,
      'photoUrl': photoUrl,
    };
  }
}
