import 'package:cloud_firestore/cloud_firestore.dart';

enum EnrollmentRequestStatus { pending, approved, rejected }

extension EnrollmentRequestStatusX on EnrollmentRequestStatus {
  String get value => name;

  static EnrollmentRequestStatus fromString(String value) {
    return EnrollmentRequestStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => EnrollmentRequestStatus.pending,
    );
  }
}

/// Mirrors a document in /enrollmentRequests/{id}.
/// Created by a secretary/admin at intake (walk-in registration). Approving
/// one (via the `approveEnrollment` Cloud Function) creates the /students
/// document and, if needed, a parent Auth account + custom claims — never
/// done as a direct client write.
class EnrollmentRequest {
  final String id;
  final String studentFirstName;
  final String studentLastName;
  final DateTime? dob;
  final String? sex;
  final String classId;
  final String parentFullName;
  final String parentEmail;
  final String? parentPhone;
  /// Optional second parent — approveEnrollment creates a login for them too
  /// (both parentFullName/parentEmail are required together).
  final String? parent2FullName;
  final String? parent2Email;
  final String? parent2Phone;
  /// Optional: when set, approveEnrollment also creates a student login
  /// (schools may prefer parent-only access, hence optional).
  final String? studentEmail;
  final EnrollmentRequestStatus status;
  final String? linkedStudentId;
  final String? linkedParentUid;
  final DateTime? createdAt;

  const EnrollmentRequest({
    required this.id,
    required this.studentFirstName,
    required this.studentLastName,
    required this.classId,
    required this.parentFullName,
    required this.parentEmail,
    this.dob,
    this.sex,
    this.parentPhone,
    this.parent2FullName,
    this.parent2Email,
    this.parent2Phone,
    this.studentEmail,
    this.status = EnrollmentRequestStatus.pending,
    this.linkedStudentId,
    this.linkedParentUid,
    this.createdAt,
  });

  factory EnrollmentRequest.fromMap(String id, Map<String, dynamic> map) {
    return EnrollmentRequest(
      id: id,
      studentFirstName: map['studentFirstName'] as String? ?? '',
      studentLastName: map['studentLastName'] as String? ?? '',
      dob: map['dob'] != null ? DateTime.tryParse(map['dob'] as String) : null,
      sex: map['sex'] as String?,
      classId: map['classId'] as String? ?? '',
      parentFullName: map['parentFullName'] as String? ?? '',
      parentEmail: map['parentEmail'] as String? ?? '',
      parentPhone: map['parentPhone'] as String?,
      parent2FullName: map['parent2FullName'] as String?,
      parent2Email: map['parent2Email'] as String?,
      parent2Phone: map['parent2Phone'] as String?,
      studentEmail: map['studentEmail'] as String?,
      status: EnrollmentRequestStatusX.fromString(map['status'] as String? ?? 'pending'),
      linkedStudentId: map['linkedStudentId'] as String?,
      linkedParentUid: map['linkedParentUid'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentFirstName': studentFirstName,
      'studentLastName': studentLastName,
      'dob': dob?.toIso8601String(),
      'sex': sex,
      'classId': classId,
      'parentFullName': parentFullName,
      'parentEmail': parentEmail,
      'parentPhone': parentPhone,
      'parent2FullName': parent2FullName,
      'parent2Email': parent2Email,
      'parent2Phone': parent2Phone,
      'studentEmail': studentEmail,
      'status': status.value,
      'linkedStudentId': linkedStudentId,
      'linkedParentUid': linkedParentUid,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
