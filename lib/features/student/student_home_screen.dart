import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/student.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import '../shared/assignments_list_view.dart';
import '../shared/async_error_view.dart';
import '../shared/attendance_summary_view.dart';
import '../shared/grades_report_view.dart';
import '../shared/my_profile_screen.dart';
import '../shared/notifications_view.dart';

/// A student's own dashboard: report card, attendance history, and upcoming
/// assignments — no fee balance here, that's parent-only (see
/// ChildDetailScreen). Requires the `studentId` custom claim, which only
/// exists for accounts created with a student login (optional per school).
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentIdAsync = ref.watch(currentStudentIdProvider);
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final l10n = AppLocalizations.of(context)!;

    return studentIdAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(l10n.errorPrefix(e)))),
      data: (studentId) {
        if (studentId == null) {
          return Scaffold(
            body: Center(child: Text(l10n.noStudentLinked)),
          );
        }
        return StreamBuilder<Student?>(
          stream: ref.watch(firestoreServiceProvider).watchStudent(studentId),
          builder: (context, snapshot) {
            final student = snapshot.data;
            if (snapshot.hasError) {
              return Scaffold(body: AsyncErrorView(error: snapshot.error));
            }
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (student == null) {
              return Scaffold(body: Center(child: Text(l10n.studentRecordNotFound)));
            }

            final activeYearAsync = ref.watch(activeSchoolYearProvider);

            return activeYearAsync.when(
              loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
              error: (e, _) => Scaffold(body: Center(child: Text(l10n.errorPrefix(e)))),
              data: (year) {
                if (year == null) {
                  return Scaffold(body: Center(child: Text(l10n.noActiveSchoolYear)));
                }
                return DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(student.fullName),
                      bottom: TabBar(tabs: [
                        Tab(text: l10n.reportCardTab),
                        Tab(text: l10n.navAttendance),
                        Tab(text: l10n.navAssignments),
                      ]),
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
                    body: TabBarView(
                      children: [
                        GradesReportView(
                          studentId: student.id,
                          studentName: student.fullName,
                          classId: student.classId,
                          yearId: year.id,
                          yearLabel: year.label,
                        ),
                        AttendanceSummaryView(studentId: student.id),
                        AssignmentsListView(classId: student.classId),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
