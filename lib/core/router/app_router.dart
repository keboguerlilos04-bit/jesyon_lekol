import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user_role.dart';
import '../services/providers.dart';
import '../../features/admin/admin_home_screen.dart';
import '../../features/auth/change_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/parent/parent_home_screen.dart';
import '../../features/shared/splash_screen.dart';
import '../../features/shared/unauthorized_screen.dart';
import '../../features/student/student_home_screen.dart';
import '../../features/teacher/teacher_home_screen.dart';

const kLoginRoute = '/login';
const kSplashRoute = '/splash';
const kUnauthorizedRoute = '/unauthorized';
const kChangePasswordRoute = '/change-password';

const Map<UserRole, String> kRoleHomeRoute = {
  UserRole.admin: '/admin',
  UserRole.teacher: '/teacher',
  UserRole.parent: '/parent',
  UserRole.student: '/student',
};

/// A bare Listenable that go_router polls via `notifyListeners()`.
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);

  // ref.listen's callback only fires AFTER authStateProvider's own state has
  // been updated, so `redirect` reading ref.read(authStateProvider) below
  // can never observe a stale value when notifyListeners triggers it. An
  // earlier version wired a second, independent authStateChanges()
  // subscription into a raw ChangeNotifier instead — that could fire
  // notifyListeners() before Riverpod's own subscription had updated
  // authStateProvider, permanently stranding the app on the splash screen.
  ref.listen(authStateProvider, (_, _) => refreshNotifier.notify());

  return GoRouter(
    initialLocation: kSplashRoute,
    refreshListenable: refreshNotifier,
    routes: [
      GoRoute(path: kSplashRoute, builder: (context, state) => const SplashScreen()),
      GoRoute(path: kLoginRoute, builder: (context, state) => const LoginScreen()),
      GoRoute(path: kUnauthorizedRoute, builder: (context, state) => const UnauthorizedScreen()),
      GoRoute(path: kChangePasswordRoute, builder: (context, state) => const ChangePasswordScreen()),
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
      // Called directly on AuthService rather than through
      // currentRoleProvider.future: reading a FutureProvider's `.future`
      // right as its `authStateProvider` dependency changes can hand back a
      // Future tied to the just-invalidated computation, which Riverpod then
      // abandons in favor of a fresh one — so it never completes and this
      // redirect hangs forever. Calling fetchRole() directly has no such
      // dependency-invalidation race.
      final role = await container.read(authServiceProvider).fetchRole();
      if (role == null) {
        // Token doesn't carry a role claim yet (e.g. brand new account
        // whose claims haven't propagated). Force a fresh token next time.
        return kUnauthorizedRoute;
      }

      final homeRoute = kRoleHomeRoute[role]!;
      final onChangePassword = state.matchedLocation == kChangePasswordRoute;

      // A freshly created account (createStaffAccount/approveEnrollment) is
      // flagged mustChangePassword — block every other route until they set
      // a real password. Read directly (not through a FutureProvider) for
      // the same reason fetchRole() is called directly above.
      final appUser = await container.read(firestoreServiceProvider).getUser(user.uid);
      if (appUser?.mustChangePassword == true) {
        return onChangePassword ? null : kChangePasswordRoute;
      }
      if (onChangePassword) {
        // They just cleared the flag (or navigated here manually with
        // nothing to change) — nothing left to do on this screen.
        return homeRoute;
      }

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
