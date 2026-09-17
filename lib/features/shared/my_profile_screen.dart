import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/app_user.dart';
import '../../core/models/profile_change_request.dart';
import '../../core/models/student.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import 'async_error_view.dart';

/// Every account holder's own read-only profile, with a "request a change"
/// action per locked field (fullName, email, phone, and — for a student —
/// sex/classId) instead of letting them edit it directly. See
/// firestore.rules on /users and /students, and admin's
/// ProfileChangeRequestsScreen for the approval side.
class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appUserAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProfileTitle)),
      body: appUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorPrefix(e))),
        data: (appUser) {
          if (appUser == null) {
            return Center(child: Text(l10n.studentRecordNotFound));
          }
          return _ProfileBody(appUser: appUser);
        },
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.appUser});

  final AppUser appUser;

  Future<void> _requestChange(
    BuildContext context,
    WidgetRef ref, {
    required String targetCollection,
    required String targetId,
    required ProfileField field,
    required String label,
    required String currentValue,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentValue);
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.requestChangeTitle(label)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: l10n.newValueField),
            validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await ref.read(firestoreServiceProvider).createProfileChangeRequest(
                    ProfileChangeRequest(
                      id: '',
                      uid: appUser.uid,
                      requesterName: appUser.fullName,
                      targetCollection: targetCollection,
                      targetId: targetId,
                      field: field,
                      currentValue: currentValue,
                      requestedValue: controller.text.trim(),
                    ),
                  );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.changeRequestSent)));
              }
            },
            child: Text(l10n.submitButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final studentIdAsync = ref.watch(currentStudentIdProvider);

    return ListView(
      children: [
        _LockedField(
          label: l10n.fullNameField,
          value: appUser.fullName,
          onRequestChange: () => _requestChange(
            context,
            ref,
            targetCollection: 'users',
            targetId: appUser.uid,
            field: ProfileField.fullName,
            label: l10n.fullNameField,
            currentValue: appUser.fullName,
          ),
        ),
        _LockedField(
          label: l10n.email,
          value: appUser.email,
          onRequestChange: () => _requestChange(
            context,
            ref,
            targetCollection: 'users',
            targetId: appUser.uid,
            field: ProfileField.email,
            label: l10n.email,
            currentValue: appUser.email,
          ),
        ),
        _LockedField(
          label: l10n.parentPhoneField,
          value: appUser.phone ?? '—',
          onRequestChange: () => _requestChange(
            context,
            ref,
            targetCollection: 'users',
            targetId: appUser.uid,
            field: ProfileField.phone,
            label: l10n.parentPhoneField,
            currentValue: appUser.phone ?? '',
          ),
        ),
        studentIdAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
          data: (studentId) {
            if (studentId == null) return const SizedBox.shrink();
            return StreamBuilder<Student?>(
              stream: ref.watch(firestoreServiceProvider).watchStudent(studentId),
              builder: (context, snapshot) {
                if (snapshot.hasError) return AsyncErrorView(error: snapshot.error);
                final student = snapshot.data;
                if (student == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    _LockedField(
                      label: l10n.sexField,
                      value: student.sex ?? '—',
                      onRequestChange: () => _requestChange(
                        context,
                        ref,
                        targetCollection: 'students',
                        targetId: studentId,
                        field: ProfileField.sex,
                        label: l10n.sexField,
                        currentValue: student.sex ?? '',
                      ),
                    ),
                    _LockedField(
                      label: l10n.classLabel,
                      value: student.classId,
                      onRequestChange: () => _requestChange(
                        context,
                        ref,
                        targetCollection: 'students',
                        targetId: studentId,
                        field: ProfileField.classId,
                        label: l10n.classLabel,
                        currentValue: student.classId,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l10n.myChangeRequestsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        StreamBuilder<List<ProfileChangeRequest>>(
          stream: ref.watch(firestoreServiceProvider).watchMyProfileChangeRequests(appUser.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) return AsyncErrorView(error: snapshot.error);
            final requests = snapshot.data ?? const <ProfileChangeRequest>[];
            if (requests.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.noRequests),
              );
            }
            return Column(
              children: [
                for (final r in requests)
                  ListTile(
                    title: Text('${_fieldLabel(l10n, r.field)}: ${r.requestedValue}'),
                    subtitle: Text(_statusLabel(l10n, r.status)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _fieldLabel(AppLocalizations l10n, ProfileField field) {
    switch (field) {
      case ProfileField.fullName:
        return l10n.fullNameField;
      case ProfileField.email:
        return l10n.email;
      case ProfileField.phone:
        return l10n.parentPhoneField;
      case ProfileField.sex:
        return l10n.sexField;
      case ProfileField.classId:
        return l10n.classLabel;
      case ProfileField.role:
        return l10n.appAccessLabel;
    }
  }

  String _statusLabel(AppLocalizations l10n, ProfileChangeStatus status) {
    switch (status) {
      case ProfileChangeStatus.pending:
        return l10n.pendingTab;
      case ProfileChangeStatus.approved:
        return l10n.approvedTab;
      case ProfileChangeStatus.rejected:
        return l10n.rejectedTab;
    }
  }
}

class _LockedField extends StatelessWidget {
  const _LockedField({required this.label, required this.value, required this.onRequestChange});

  final String label;
  final String value;
  final VoidCallback onRequestChange;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined),
        tooltip: AppLocalizations.of(context)!.requestChangeTooltip,
        onPressed: onRequestChange,
      ),
    );
  }
}
