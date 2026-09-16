import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(AppLocalizations.of(context)!.unauthorizedMessage)),
    );
  }
}
