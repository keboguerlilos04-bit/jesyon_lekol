import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'firebase_options.dart';

/// Run with `flutter run --dart-define=USE_FUNCTIONS_EMULATOR=true` to call
/// Cloud Functions against a local `firebase emulators:start --only functions`
/// instance instead of a deployed one. Everything else (Auth, Firestore)
/// still talks to the real `jesyon-lekol` project — this exists because
/// Cloud Functions deployment requires the Blaze plan, which this project
/// isn't on yet; the emulator lets createStaffAccount/approveEnrollment be
/// exercised for free during development in the meantime.
const _useFunctionsEmulator = bool.fromEnvironment('USE_FUNCTIONS_EMULATOR');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (_useFunctionsEmulator) {
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }
  runApp(const ProviderScope(child: JesyonLekolApp()));
}

class JesyonLekolApp extends ConsumerWidget {
  const JesyonLekolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Jesyon Lekòl',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      routerConfig: router,
    );
  }
}
