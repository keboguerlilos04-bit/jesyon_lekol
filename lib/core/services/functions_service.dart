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
    try {
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
        tempPassword: data['tempPassword'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      throw FunctionsCallException(_friendlyMessage(e));
    }
  }

  Future<ApproveEnrollmentResult> approveEnrollment(String requestId) async {
    try {
      final callable = _functions.httpsCallable('approveEnrollment');
      final result = await callable.call<Map<String, dynamic>>({'requestId': requestId});
      final data = Map<String, dynamic>.from(result.data as Map);
      final accounts = (data['accounts'] as List? ?? [])
          .map((a) => NewAccountCredential.fromMap(Map<String, dynamic>.from(a as Map)))
          .toList();
      return ApproveEnrollmentResult(
        studentId: data['studentId'] as String,
        parentUid: data['parentUid'] as String,
        accounts: accounts,
      );
    } on FirebaseFunctionsException catch (e) {
      throw FunctionsCallException(_friendlyMessage(e));
    }
  }

  /// Admin-only: approves or rejects a locked-field change request whose
  /// [field] is 'email' or 'role' — every other field is patched directly
  /// by the admin UI via a plain Firestore write instead of this call.
  Future<void> applyProfileChangeRequest({
    required String requestId,
    required bool approve,
    String? adminNote,
  }) async {
    try {
      final callable = _functions.httpsCallable('applyProfileChangeRequest');
      await callable.call<Map<String, dynamic>>({
        'requestId': requestId,
        'approve': approve,
        'adminNote': adminNote,
      });
    } on FirebaseFunctionsException catch (e) {
      throw FunctionsCallException(_friendlyMessage(e));
    }
  }

  /// Maps a raw FirebaseFunctionsException (e.g. "[cloud_functions/not-found]
  /// NOT_FOUND") to a short, non-technical message a school secretary can
  /// actually act on, instead of the caller displaying the raw exception —
  /// or worse, a stack trace — straight on screen.
  String _friendlyMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'not-found':
        return 'Sèvis sa a poko konfigire sou sèvè a. Kontakte administratè teknik la.';
      case 'unauthenticated':
        return 'Ou pa konekte. Rekonekte epi eseye ankò.';
      case 'permission-denied':
        return 'Ou pa gen dwa pou fè aksyon sa a.';
      case 'already-exists':
        return 'Yon kont deja egziste ak email sa a.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Sèvè a pa reponn kounye a. Tanpri eseye ankò nan kèk minit.';
      default:
        return e.message ?? 'Yon erè enkoni pase (${e.code}).';
    }
  }
}

/// Carries a message already safe to show a user directly (no error code,
/// no stack trace) — see FunctionsService._friendlyMessage.
class FunctionsCallException implements Exception {
  const FunctionsCallException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CreateStaffResult {
  final String uid;
  final String? tempPassword;
  const CreateStaffResult({required this.uid, this.tempPassword});
}

/// One freshly created login handed back so the admin can share it once —
/// email/tempPassword are never persisted anywhere in plaintext.
class NewAccountCredential {
  final String role;
  final String email;
  final String? tempPassword; // null when this account already existed
  const NewAccountCredential({required this.role, required this.email, this.tempPassword});

  factory NewAccountCredential.fromMap(Map<String, dynamic> map) {
    return NewAccountCredential(
      role: map['role'] as String? ?? '',
      email: map['email'] as String? ?? '',
      tempPassword: map['tempPassword'] as String?,
    );
  }
}

class ApproveEnrollmentResult {
  final String studentId;
  final String parentUid;
  final List<NewAccountCredential> accounts;
  const ApproveEnrollmentResult({
    required this.studentId,
    required this.parentUid,
    this.accounts = const [],
  });
}
