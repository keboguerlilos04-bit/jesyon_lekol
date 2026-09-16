import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/student.dart';
import '../../core/services/providers.dart';
import '../shared/assignments_list_view.dart';
import '../shared/attendance_summary_view.dart';
import '../shared/grades_report_view.dart';
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

    return studentIdAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erè: $e'))),
      data: (studentId) {
        if (studentId == null) {
          return const Scaffold(
            body: Center(child: Text('Kont sa a pa lye ak yon dosye elèv.')),
          );
        }
        return StreamBuilder<Student?>(
          stream: ref.watch(firestoreServiceProvider).watchStudent(studentId),
          builder: (context, snapshot) {
            final student = snapshot.data;
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (student == null) {
              return const Scaffold(body: Center(child: Text('Dosye elèv la pa jwenn.')));
            }

            final activeYearAsync = ref.watch(activeSchoolYearProvider);

            return activeYearAsync.when(
              loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
              error: (e, _) => Scaffold(body: Center(child: Text('Erè: $e'))),
              data: (year) {
                if (year == null) {
                  return const Scaffold(body: Center(child: Text('Pa gen ane lekòl aktif kounye a.')));
                }
                return DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(student.fullName),
                      bottom: const TabBar(tabs: [
                        Tab(text: 'Bilten'),
                        Tab(text: 'Prezans'),
                        Tab(text: 'Devwa'),
                      ]),
                      actions: [
                        if (uid != null)
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            tooltip: 'Notifikasyon',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => NotificationsScreen(uid: uid)),
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
                        GradesReportView(studentId: student.id, classId: student.classId, yearId: year.id),
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
