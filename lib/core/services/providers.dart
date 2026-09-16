import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/school_year.dart';
import '../models/teacher_profile.dart';
import '../models/user_role.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'functions_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) => FirebaseFunctions.instance);

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref.watch(firestoreProvider));
});

final functionsServiceProvider = Provider<FunctionsService>((ref) {
  return FunctionsService(ref.watch(firebaseFunctionsProvider));
});

/// Emits whenever the Firebase Auth sign-in state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// Resolves the signed-in user's role from custom claims. This is what
/// go_router's redirect logic uses to gate whole sections of the app.
final currentRoleProvider = FutureProvider<UserRole?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return null;
  return ref.watch(authServiceProvider).fetchRole();
});

/// studentIds claim — populated for parent accounts (their children). Used
/// to scope UI-level queries (in addition to Security Rules).
final currentStudentIdsProvider = FutureProvider<List<String>>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return const [];
  return ref.watch(authServiceProvider).fetchStudentIds();
});

/// studentId claim (singular) — populated only for a student's own login.
final currentStudentIdProvider = FutureProvider<String?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return null;
  return ref.watch(authServiceProvider).fetchStudentId();
});

/// /users/{uid} profile document for the signed-in user.
final currentAppUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return null;
  return ref.watch(firestoreServiceProvider).getUser(authState.uid);
});

/// /teachers/{uid} profile (classIds/subjectIds) for the signed-in teacher.
final currentTeacherProfileProvider = FutureProvider<TeacherProfile?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return null;
  return ref.watch(firestoreServiceProvider).getTeacherProfile(authState.uid);
});

/// The school year currently marked `active: true`, if any. Grade and
/// attendance entry are scoped to it so old years stay read-only history.
final activeSchoolYearProvider = StreamProvider<SchoolYear?>((ref) {
  return ref.watch(firestoreServiceProvider).watchSchoolYears().map((years) {
    for (final y in years) {
      if (y.active) return y;
    }
    return null;
  });
});
