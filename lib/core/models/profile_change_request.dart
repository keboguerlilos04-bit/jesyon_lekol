import 'package:cloud_firestore/cloud_firestore.dart';

enum ProfileChangeStatus { pending, approved, rejected }

extension ProfileChangeStatusX on ProfileChangeStatus {
  String get value => name;

  static ProfileChangeStatus fromString(String value) {
    return ProfileChangeStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ProfileChangeStatus.pending,
    );
  }
}

/// One field a user cannot edit directly (see firestore.rules on /users and
/// /students) that they're instead requesting an admin approve. [field] is
/// one of: fullName, email, phone, sex, classId, role.
enum ProfileField { fullName, email, phone, sex, classId, role }

extension ProfileFieldX on ProfileField {
  String get value => name;

  /// email/role changes touch Firebase Auth itself (login email, custom
  /// claims), so approving one goes through applyProfileChangeRequest
  /// instead of a plain Firestore write — see FirestoreService.
  bool get needsCloudFunction => this == ProfileField.email || this == ProfileField.role;

  static ProfileField fromString(String value) {
    return ProfileField.values.firstWhere((f) => f.name == value, orElse: () => ProfileField.fullName);
  }
}

/// Mirrors a document in /profileChangeRequests/{id}. [targetCollection] +
/// [targetId] name the document an approval eventually patches — 'users'
/// for fullName/email/phone/role, 'students' for sex/classId.
class ProfileChangeRequest {
  final String id;
  final String uid; // requester
  final String requesterName;
  final String targetCollection;
  final String targetId;
  final ProfileField field;
  final String currentValue;
  final String requestedValue;
  final ProfileChangeStatus status;
  final String? reviewedBy;
  final String? adminNote;
  final DateTime? createdAt;

  const ProfileChangeRequest({
    required this.id,
    required this.uid,
    required this.requesterName,
    required this.targetCollection,
    required this.targetId,
    required this.field,
    required this.currentValue,
    required this.requestedValue,
    this.status = ProfileChangeStatus.pending,
    this.reviewedBy,
    this.adminNote,
    this.createdAt,
  });

  factory ProfileChangeRequest.fromMap(String id, Map<String, dynamic> map) {
    return ProfileChangeRequest(
      id: id,
      uid: map['uid'] as String? ?? '',
      requesterName: map['requesterName'] as String? ?? '',
      targetCollection: map['targetCollection'] as String? ?? 'users',
      targetId: map['targetId'] as String? ?? '',
      field: ProfileFieldX.fromString(map['field'] as String? ?? 'fullName'),
      currentValue: map['currentValue'] as String? ?? '',
      requestedValue: map['requestedValue'] as String? ?? '',
      status: ProfileChangeStatusX.fromString(map['status'] as String? ?? 'pending'),
      reviewedBy: map['reviewedBy'] as String?,
      adminNote: map['adminNote'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'requesterName': requesterName,
      'targetCollection': targetCollection,
      'targetId': targetId,
      'field': field.value,
      'currentValue': currentValue,
      'requestedValue': requestedValue,
      'status': status.value,
      'reviewedBy': reviewedBy,
      'adminNote': adminNote,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
