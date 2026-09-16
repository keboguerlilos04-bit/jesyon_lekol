import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/class_model.dart';
import '../../core/models/enrollment_request.dart';
import '../../core/services/providers.dart';

class EnrollmentRequestsScreen extends ConsumerWidget {
  const EnrollmentRequestsScreen({super.key});

  Future<void> _openCreateForm(BuildContext context, WidgetRef ref, List<ClassModel> classes) async {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final parentNameController = TextEditingController();
    final parentEmailController = TextEditingController();
    final parentPhoneController = TextEditingController();
    String? classId = classes.isEmpty ? null : classes.first.id;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouvo Demann Enskripsyon'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(labelText: 'Prenon elèv'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Obligatwa' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(labelText: 'Non fanmi elèv'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Obligatwa' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: classId,
                      decoration: const InputDecoration(labelText: 'Klas'),
                      items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (v) => setState(() => classId = v),
                    ),
                    const Divider(height: 32),
                    TextFormField(
                      controller: parentNameController,
                      decoration: const InputDecoration(labelText: 'Non konplè paran'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Obligatwa' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: parentEmailController,
                      decoration: const InputDecoration(labelText: 'Email paran'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@')) ? 'Email envalid' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: parentPhoneController,
                      decoration: const InputDecoration(labelText: 'Telefòn paran (opsyonèl)'),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anile')),
            FilledButton(
              onPressed: classId == null
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final id =
                          ref.read(firestoreProvider).collection('enrollmentRequests').doc().id;
                      await ref.read(firestoreServiceProvider).createEnrollmentRequest(
                            EnrollmentRequest(
                              id: id,
                              studentFirstName: firstNameController.text.trim(),
                              studentLastName: lastNameController.text.trim(),
                              classId: classId!,
                              parentFullName: parentNameController.text.trim(),
                              parentEmail: parentEmailController.text.trim(),
                              parentPhone: parentPhoneController.text.trim().isEmpty
                                  ? null
                                  : parentPhoneController.text.trim(),
                            ),
                          );
                      if (context.mounted) Navigator.pop(context);
                    },
              child: const Text('Soumèt'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref, EnrollmentRequest request) async {
    try {
      final result = await ref.read(functionsServiceProvider).approveEnrollment(request.id);
      if (!context.mounted) return;
      if (result.passwordResetLink != null) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enskripsyon apwouve'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kont paran an kreye. Voye lyen sa a ba li pou li defini modpas li:'),
                const SizedBox(height: 8),
                SelectableText(result.passwordResetLink!),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fèmen')),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erè: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surface,
              child: const TabBar(tabs: [
                Tab(text: 'Annatant'),
                Tab(text: 'Apwouve'),
                Tab(text: 'Rejte'),
              ]),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _RequestList(status: EnrollmentRequestStatus.pending, onApprove: _approve),
                  _RequestList(status: EnrollmentRequestStatus.approved, onApprove: _approve),
                  _RequestList(status: EnrollmentRequestStatus.rejected, onApprove: _approve),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: StreamBuilder<List<ClassModel>>(
          stream: ref.watch(firestoreServiceProvider).watchClasses(),
          builder: (context, snapshot) {
            final classes = snapshot.data ?? const [];
            return FloatingActionButton(
              onPressed: classes.isEmpty
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kreye yon klas anvan.')),
                      )
                  : () => _openCreateForm(context, ref, classes),
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

class _RequestList extends ConsumerWidget {
  const _RequestList({required this.status, required this.onApprove});

  final EnrollmentRequestStatus status;
  final Future<void> Function(BuildContext, WidgetRef, EnrollmentRequest) onApprove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<EnrollmentRequest>>(
      stream: ref.watch(firestoreServiceProvider).watchEnrollmentRequests(status: status),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final requests = snapshot.data!;
        if (requests.isEmpty) return const Center(child: Text('Pa gen anyen isit la.'));
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, i) {
            final r = requests[i];
            return ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text('${r.studentFirstName} ${r.studentLastName}'),
              subtitle: Text('Paran: ${r.parentFullName} • ${r.parentEmail}'),
              trailing: status == EnrollmentRequestStatus.pending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'Rejte',
                          onPressed: () => ref.read(firestoreServiceProvider).rejectEnrollmentRequest(r.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          tooltip: 'Apwouve',
                          onPressed: () => onApprove(context, ref, r),
                        ),
                      ],
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
