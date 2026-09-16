import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user_role.dart';
import '../services/providers.dart';
import '../../features/admin/admin_home_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/parent/parent_home_screen.dart';
import '../../features/shared/splash_screen.dart';
import '../../features/shared/unauthorized_screen.dart';
import '../../features/student/student_home_screen.dart';
import '../../features/teacher/teacher_home_screen.dart';

const kLoginRoute = '/login';
const kSplashRoute = '/splash';
const kUnauthorizedRoute = '/unauthorized';

const Map<UserRole, String> kRoleHomeRoute = {
  UserRole.admin: '/admin',
  UserRole.teacher: '/teacher',
  UserRole.parent: '/parent',
  UserRole.student: '/student',
};

/// Bridges a Stream (Firebase auth state) to a Listenable so go_router
/// re-evaluates its `redirect` callback whenever sign-in state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshStream = GoRouterRefreshStream(
    ref.watch(authServiceProvider).authStateChanges(),
  );
  ref.onDispose(refreshStream.dispose);

  return GoRouter(
    initialLocation: kSplashRoute,
    refreshListenable: refreshStream,
    routes: [
      GoRoute(path: kSplashRoute, builder: (context, state) => const SplashScreen()),
      GoRoute(path: kLoginRoute, builder: (context, state) => const LoginScreen()),
      GoRoute(path: kUnauthorizedRoute, builder: (context, state) => const UnauthorizedScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminHomeScreen()),
      GoRoute(path: '/teacher', builder: (context, state) => const TeacherHomeScreen()),
      GoRoute(path: '/parent', builder: (context, state) => const ParentHomeScreen()),
      GoRoute(path: '/student', builder: (context, state) => const StudentHomeScreen()),
    ],
    redirect: (context, state) async {
      final container = ref;
      final authState = container.read(authStateProvider);

      // Auth plugin hasn't reported yet: keep the splash screen up.
      if (authState.isLoading) return kSplashRoute;

      final user = authState.value;
      final loggingIn = state.matchedLocation == kLoginRoute;
      final onSplash = state.matchedLocation == kSplashRoute;

      if (user == null) {
        return loggingIn ? null : kLoginRoute;
      }

      // Signed in: resolve role from custom claims (set by the
      // account-creation Cloud Function — never trust client-side state).
      final role = await container.read(currentRoleProvider.future);
      if (role == null) {
        // Token doesn't carry a role claim yet (e.g. brand new account
        // whose claims haven't propagated). Force a fresh token next time.
        return kUnauthorizedRoute;
      }

      final homeRoute = kRoleHomeRoute[role]!;

      if (loggingIn || onSplash) return homeRoute;

      // Prevent, e.g., a signed-in student from typing /admin in the
      // browser's address bar on web.
      final allowedForRole = homeRoute == state.matchedLocation;
      if (!allowedForRole && kRoleHomeRoute.values.contains(state.matchedLocation)) {
        return homeRoute;
      }

      return null;
    },
  );
});
