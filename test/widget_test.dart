import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jesyon_lekol/main.dart';
import 'package:jesyon_lekol/features/auth/login_screen.dart';
import 'package:jesyon_lekol/l10n/app_localizations.dart';

void main() {
  testWidgets('Login screen shows email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('ht'),
          localizationsDelegates: jesyonLekolLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Jesyon Lekòl'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Modpas'), findsOneWidget);
  });
}
