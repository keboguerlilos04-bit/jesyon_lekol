import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/app_user.dart';
import '../../core/models/user_role.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import '../shared/async_error_view.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  Future<void> _openCreateForm(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final positionController = TextEditingController();
    UserRole appRole = UserRole.teacher;
    bool submitting = false;
    String? error;
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.newStaffTitle),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.fullNameField),
                  validator: (v) => (v == null || v.isEmpty) ? l10n.required : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: l10n.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? l10n.invalidEmail : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: positionController,
                  decoration: InputDecoration(labelText: l10n.positionField),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  initialValue: appRole,
                  decoration: InputDecoration(labelText: l10n.appAccessLabel),
                  items: [
                    DropdownMenuItem(value: UserRole.teacher, child: Text(l10n.roleTeacherOption)),
                    DropdownMenuItem(value: UserRole.admin, child: Text(l10n.roleAdminOption)),
                  ],
                  onChanged: (v) => setState(() => appRole = v ?? UserRole.teacher),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() {
                        submitting = true;
                        error = null;
                      });
                      try {
                        final result = await ref.read(functionsServiceProvider).createStaffAccount(
                              fullName: nameController.text.trim(),
                              email: emailController.text.trim(),
                              role: appRole.value,
                              position: positionController.text.trim(),
                            );
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (result.passwordResetLink != null) {
                            await _showPasswordLinkDialog(context, result.passwordResetLink!);
                          }
                        }
                      } catch (e) {
                        setState(() {
                          error = l10n.createAccountFailed(e);
                          submitting = false;
                        });
                      }
                    },
              child: submitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.createAccountButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPasswordLinkDialog(BuildContext context, String link) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountCreatedTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.sendLinkToStaffBody),
            const SizedBox(height: 8),
            SelectableText(link),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: StreamBuilder<List<AppUser>>(
        stream: ref.watch(firestoreServiceProvider).watchStaff(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return AsyncErrorView(error: snapshot.error);
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final staff = snapshot.data!;
          if (staff.isEmpty) {
            return Center(child: Text(l10n.noStaff));
          }
          return ListView.builder(
            itemCount: staff.length,
            itemBuilder: (context, i) {
              final u = staff[i];
              return ListTile(
                leading: CircleAvatar(child: Text(u.fullName.isNotEmpty ? u.fullName[0] : '?')),
                title: Text(u.fullName),
                subtitle: Text('${u.position ?? u.role.value} • ${u.email}'),
                trailing: u.active ? null : Chip(label: Text(l10n.inactiveChip)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateForm(context, ref),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
