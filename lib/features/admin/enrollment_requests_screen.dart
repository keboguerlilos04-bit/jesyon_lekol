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
    final studentEmailController = TextEditingController();
    final parentNameController = TextEditingController();
    final parentEmailController = TextEditingController();
    final parentPhoneController = TextEditingController();
    final parent2NameController = TextEditingController();
    final parent2EmailController = TextEditingController();
    final parent2PhoneController = TextEditingController();
    String? classId = classes.isEmpty ? null : classes.first.id;
    bool addSecondParent = false;
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
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.classLabel),
                      items: classes
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setState(() => classId = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: studentEmailController,
                      decoration: InputDecoration(labelText: l10n.studentEmailOptionalField),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          (v != null && v.isNotEmpty && !v.contains('@')) ? l10n.invalidEmail : null,
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
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.addSecondParentToggle),
                      value: addSecondParent,
                      onChanged: (v) => setState(() => addSecondParent = v),
                    ),
                    if (addSecondParent) ...[
                      TextFormField(
                        controller: parent2NameController,
                        decoration: InputDecoration(labelText: l10n.parent2FullNameField),
                        validator: (v) =>
                            (addSecondParent && (v == null || v.isEmpty)) ? l10n.required : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: parent2EmailController,
                        decoration: InputDecoration(labelText: l10n.parent2EmailField),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (addSecondParent && (v == null || !v.contains('@')))
                            ? l10n.invalidEmail
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: parent2PhoneController,
                        decoration: InputDecoration(labelText: l10n.parentPhoneField),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
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
                              studentEmail: studentEmailController.text.trim().isEmpty
                                  ? null
                                  : studentEmailController.text.trim(),
                              parentFullName: parentNameController.text.trim(),
                              parentEmail: parentEmailController.text.trim(),
                              parentPhone: parentPhoneController.text.trim().isEmpty
                                  ? null
                                  : parentPhoneController.text.trim(),
                              parent2FullName: addSecondParent ? parent2NameController.text.trim() : null,
                              parent2Email: addSecondParent ? parent2EmailController.text.trim() : null,
                              parent2Phone: addSecondParent && parent2PhoneController.text.trim().isNotEmpty
                                  ? parent2PhoneController.text.trim()
                                  : null,
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
      if (result.accounts.isNotEmpty) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.enrollmentApprovedTitle),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.newAccountsCreatedBody),
                    for (final account in result.accounts) ...[
                      const Divider(height: 24),
                      Text(
                        account.role == 'student' ? l10n.studentField : l10n.parentRoleLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SelectableText('${l10n.email}: ${account.email}'),
                      if (account.tempPassword != null)
                        SelectableText('${l10n.temporaryPasswordLabel}: ${account.tempPassword}')
                      else
                        Text(l10n.accountAlreadyExisted, style: const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
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
