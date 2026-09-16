import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

/// Flutter's own built-in Material/Cupertino translations don't include
/// Haitian Creole, so a device/browser locale resolving to 'ht' would
/// otherwise leave things like the date picker's dialog without a
/// MaterialLocalizations instance at all (a hard crash — see
/// debugCheckHasMaterialLocalizations). These delegates cover 'ht' by
/// serving the French set instead, which every literate Haitian Creole
/// speaker reads natively; only AppLocalizations (this app's own strings)
/// actually renders in Creole.
class _HtMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _HtMaterialLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ht';
  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('fr'));
  @override
  bool shouldReload(_HtMaterialLocalizationsDelegate old) => false;
}

class _HtCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _HtCupertinoLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ht';
  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('fr'));
  @override
  bool shouldReload(_HtCupertinoLocalizationsDelegate old) => false;
}

/// Exposed so widget tests can build the same MaterialApp localization setup
/// without duplicating the Haitian Creole fallback delegates above.
const List<LocalizationsDelegate<dynamic>> jesyonLekolLocalizationsDelegates = [
  AppLocalizations.delegate,
  _HtMaterialLocalizationsDelegate(),
  _HtCupertinoLocalizationsDelegate(),
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

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
      localizationsDelegates: jesyonLekolLocalizationsDelegates,
      // Haitian Creole first so a device/browser locale outside {ht, fr, en}
      // falls back to it rather than to English — see basicLocaleListResolution.
      supportedLocales: const [Locale('ht'), Locale('fr'), Locale('en')],
    );
  }
}
