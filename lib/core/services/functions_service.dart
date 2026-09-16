import 'package:cloud_functions/cloud_functions.dart';

/// Calls the Cloud Functions that perform privileged operations (creating
/// Firebase Auth accounts + custom claims) which must never happen directly
/// from a client. See functions/src for the server-side implementation.
class FunctionsService {
  FunctionsService(this._functions);

  final FirebaseFunctions _functions;

  Future<CreateStaffResult> createStaffAccount({
    required String fullName,
    required String email,
    required String role, // 'admin' | 'teacher'
    String? position,
    List<String> subjectIds = const [],
    List<String> classIds = const [],
  }) async {
    final callable = _functions.httpsCallable('createStaffAccount');
    final result = await callable.call<Map<String, dynamic>>({
      'fullName': fullName,
      'email': email,
      'role': role,
      'position': position,
      'subjectIds': subjectIds,
      'classIds': classIds,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    return CreateStaffResult(
      uid: data['uid'] as String,
      passwordResetLink: data['passwordResetLink'] as String?,
    );
  }

  Future<ApproveEnrollmentResult> approveEnrollment(String requestId) async {
    final callable = _functions.httpsCallable('approveEnrollment');
    final result = await callable.call<Map<String, dynamic>>({'requestId': requestId});
    final data = Map<String, dynamic>.from(result.data as Map);
    return ApproveEnrollmentResult(
      studentId: data['studentId'] as String,
      parentUid: data['parentUid'] as String,
      passwordResetLink: data['passwordResetLink'] as String?,
    );
  }
}

class CreateStaffResult {
  final String uid;
  final String? passwordResetLink;
  const CreateStaffResult({required this.uid, this.passwordResetLink});
}

class ApproveEnrollmentResult {
  final String studentId;
  final String parentUid;
  final String? passwordResetLink;
  const ApproveEnrollmentResult({
    required this.studentId,
    required this.parentUid,
    this.passwordResetLink,
  });
}
