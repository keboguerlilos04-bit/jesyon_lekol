import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/class_model.dart';
import '../../core/models/enrollment_request.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import '../shared/async_error_view.dart';

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
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.newEnrollmentTitle),
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
                      decoration: InputDecoration(labelText: l10n.studentFirstNameField),
                      validator: (v) => (v == null || v.isEmpty) ? l10n.required : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: lastNameController,
                      decoration: InputDecoration(labelText: l10n.studentLastNameField),
                      validator: (v) => (v == null || v.isEmpty) ? l10n.required : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: classId,
                      decoration: InputDecoration(labelText: l10n.classLabel),
                      items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (v) => setState(() => classId = v),
                    ),
                    const Divider(height: 32),
                    TextFormField(
                      controller: parentNameController,
                      decoration: InputDecoration(labelText: l10n.parentFullNameField),
                      validator: (v) => (v == null || v.isEmpty) ? l10n.required : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: parentEmailController,
                      decoration: InputDecoration(labelText: l10n.parentEmailField),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@')) ? l10n.invalidEmail : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: parentPhoneController,
                      decoration: InputDecoration(labelText: l10n.parentPhoneField),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
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
              child: Text(l10n.submitButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref, EnrollmentRequest request) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await ref.read(functionsServiceProvider).approveEnrollment(request.id);
      if (!context.mounted) return;
      if (result.passwordResetLink != null) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.enrollmentApprovedTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.parentAccountCreatedBody),
                const SizedBox(height: 8),
                SelectableText(result.passwordResetLink!),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorPrefix(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surface,
              child: TabBar(tabs: [
                Tab(text: l10n.pendingTab),
                Tab(text: l10n.approvedTab),
                Tab(text: l10n.rejectedTab),
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
                        SnackBar(content: Text(l10n.createClassFirst)),
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
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<EnrollmentRequest>>(
      stream: ref.watch(firestoreServiceProvider).watchEnrollmentRequests(status: status),
      builder: (context, snapshot) {
        if (snapshot.hasError) return AsyncErrorView(error: snapshot.error);
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final requests = snapshot.data!;
        if (requests.isEmpty) return Center(child: Text(l10n.noRequests));
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, i) {
            final r = requests[i];
            return ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text('${r.studentFirstName} ${r.studentLastName}'),
              subtitle: Text(l10n.parentSubtitle(r.parentFullName, r.parentEmail)),
              trailing: status == EnrollmentRequestStatus.pending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: l10n.rejectTooltip,
                          onPressed: () => ref.read(firestoreServiceProvider).rejectEnrollmentRequest(r.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          tooltip: l10n.approveTooltip,
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
