import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/student.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import '../shared/async_error_view.dart';
import '../shared/my_profile_screen.dart';
import '../shared/notifications_view.dart';
import 'child_detail_screen.dart';

/// Shows every child linked to this parent's account (the studentIds custom
/// claim — see approveEnrollment). Tapping one drills into their grades,
/// attendance, assignments, and fee balance.
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentIdsAsync = ref.watch(currentStudentIdsProvider);
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myChildrenTitle),
        actions: [
          if (uid != null)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: l10n.notificationsTooltip,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationsScreen(uid: uid)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: l10n.myProfileTitle,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: studentIdsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorPrefix(e))),
        data: (studentIds) {
          if (studentIds.isEmpty) {
            return Center(child: Text(l10n.noChildrenLinked));
          }
          return StreamBuilder<List<Student>>(
            stream: ref.watch(firestoreServiceProvider).watchStudentsByIds(studentIds),
            builder: (context, snapshot) {
              if (snapshot.hasError) return AsyncErrorView(error: snapshot.error);
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final children = snapshot.data!;
              return ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, i) {
                  final s = children[i];
                  return ListTile(
                    leading: CircleAvatar(child: Text(s.firstName.isNotEmpty ? s.firstName[0] : '?')),
                    title: Text(s.fullName),
                    subtitle: Text(l10n.classIdSubtitle(s.classId)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChildDetailScreen(student: s)),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
