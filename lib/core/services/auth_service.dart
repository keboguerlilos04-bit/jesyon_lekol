import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_role.dart';

/// Thin wrapper around FirebaseAuth. Account CREATION for parents/students
/// never happens here — it is done by an admin-triggered Cloud Function so
/// custom claims (role, studentIds) are set atomically and correctly.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Reads the `role` custom claim set by the account-creation Cloud
  /// Function. Forces a token refresh so a role change takes effect without
  /// requiring the user to sign out/in again.
  Future<UserRole?> fetchRole({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final tokenResult = await user.getIdTokenResult(forceRefresh);
    final role = tokenResult.claims?['role'] as String?;
    if (role == null) return null;
    return UserRoleX.fromString(role);
  }

  /// studentIds claim, populated for parent accounts (their linked
  /// children) — used to scope Firestore reads client-side in addition to
  /// the enforcement already done in Security Rules.
  Future<List<String>> fetchStudentIds({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return const [];
    final tokenResult = await user.getIdTokenResult(forceRefresh);
    final ids = tokenResult.claims?['studentIds'];
    if (ids is List) return ids.cast<String>();
    return const [];
  }

  /// studentId claim (singular), populated only for a student's own login —
  /// matches the `isSelf()` check in firestore.rules.
  Future<String?> fetchStudentId({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final tokenResult = await user.getIdTokenResult(forceRefresh);
    return tokenResult.claims?['studentId'] as String?;
  }
}
