import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/app_user.dart';
import '../../core/models/user_role.dart';
import '../../core/services/providers.dart';

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

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouvo Anplwaye'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Non konplè'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Obligatwa' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email envalid' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: positionController,
                  decoration: const InputDecoration(labelText: 'Pozisyon (eg: Sekretè Jeneral, Pwofesè Matematik)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  initialValue: appRole,
                  decoration: const InputDecoration(labelText: 'Aksè nan aplikasyon an'),
                  items: const [
                    DropdownMenuItem(value: UserRole.teacher, child: Text('Pwofesè (nòt, prezans, devwa)')),
                    DropdownMenuItem(value: UserRole.admin, child: Text('Admin (aksè konplè)')),
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
              child: const Text('Anile'),
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
                          error = 'Pa kapab kreye kont lan: $e';
                          submitting = false;
                        });
                      }
                    },
              child: submitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Kreye Kont'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPasswordLinkDialog(BuildContext context, String link) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kont kreye'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Voye lyen sa a bay anplwaye a pou li defini modpas li:'),
            const SizedBox(height: 8),
            SelectableText(link),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fèmen')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: StreamBuilder<List<AppUser>>(
        stream: ref.watch(firestoreServiceProvider).watchStaff(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final staff = snapshot.data!;
          if (staff.isEmpty) {
            return const Center(child: Text('Poko gen anplwaye. Peze + pou ajoute youn.'));
          }
          return ListView.builder(
            itemCount: staff.length,
            itemBuilder: (context, i) {
              final u = staff[i];
              return ListTile(
                leading: CircleAvatar(child: Text(u.fullName.isNotEmpty ? u.fullName[0] : '?')),
                title: Text(u.fullName),
                subtitle: Text('${u.position ?? u.role.value} • ${u.email}'),
                trailing: u.active ? null : const Chip(label: Text('Inaktif')),
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
