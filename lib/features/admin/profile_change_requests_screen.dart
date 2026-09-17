import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/profile_change_request.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import '../shared/async_error_view.dart';

/// Admin review queue for locked-field change requests (see
/// MyProfileScreen). Approving a fullName/phone/sex/classId request writes
/// straight to the target document (admin already has unconditional write
/// there); email/role changes also touch Firebase Auth, so those go through
/// applyProfileChangeRequest instead — see FirestoreService/FunctionsService.
class ProfileChangeRequestsScreen extends ConsumerWidget {
  const ProfileChangeRequestsScreen({super.key});

  Future<void> _approve(BuildContext context, WidgetRef ref, ProfileChangeRequest request) async {
    final l10n = AppLocalizations.of(context)!;
    final adminUid = ref.read(firebaseAuthProvider).currentUser!.uid;
    try {
      if (request.field.needsCloudFunction) {
        await ref.read(functionsServiceProvider).applyProfileChangeRequest(
              requestId: request.id,
              approve: true,
            );
      } else {
        await ref.read(firestoreServiceProvider).applyDirectProfileChange(request, adminUid);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.changeApplied)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorPrefix(e))));
      }
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, ProfileChangeRequest request) async {
    final l10n = AppLocalizations.of(context)!;
    final adminUid = ref.read(firebaseAuthProvider).currentUser!.uid;
    try {
      if (request.field.needsCloudFunction) {
        await ref.read(functionsServiceProvider).applyProfileChangeRequest(
              requestId: request.id,
              approve: false,
            );
      } else {
        await ref.read(firestoreServiceProvider).rejectProfileChangeRequest(request.id, adminUid);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorPrefix(e))));
      }
    }
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<ProfileChangeRequest>>(
      stream: ref.watch(firestoreServiceProvider).watchProfileChangeRequests(status: ProfileChangeStatus.pending),
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
              leading: const Icon(Icons.edit_note_outlined),
              title: Text('${r.requesterName} — ${_fieldLabel(l10n, r.field)}'),
              subtitle: Text('"${r.currentValue}" → "${r.requestedValue}"'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: l10n.rejectTooltip,
                    onPressed: () => _reject(context, ref, r),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    tooltip: l10n.approveTooltip,
                    onPressed: () => _approve(context, ref, r),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
