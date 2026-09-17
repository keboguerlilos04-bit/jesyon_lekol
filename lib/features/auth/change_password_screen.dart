import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';

/// Shown in place of every other route (see app_router.dart) whenever the
/// signed-in account still carries `mustChangePassword: true` — set by
/// createStaffAccount/approveEnrollment on a freshly created login, so a
/// temporary password handed out by an admin is never usable for anything
/// beyond this one screen.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final user = ref.read(firebaseAuthProvider).currentUser!;
      await user.updatePassword(_passwordController.text);
      await ref.read(firestoreServiceProvider).clearMustChangePassword(user.uid);
      // The router's redirect only re-runs on an auth-state change or a
      // navigation attempt — landing back on splash forces it to
      // re-evaluate now that mustChangePassword is false.
      if (mounted) context.go('/splash');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.code == 'requires-recent-login'
            ? AppLocalizations.of(context)!.reloginRequired
            : e.message ?? e.code;
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.mustChangePasswordTitle,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.mustChangePasswordBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: l10n.newPasswordField),
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 6) ? l10n.passwordTooShort : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    decoration: InputDecoration(labelText: l10n.confirmPasswordField),
                    obscureText: true,
                    validator: (v) =>
                        v != _passwordController.text ? l10n.passwordsDontMatch : null,
                  ),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.changePasswordButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
