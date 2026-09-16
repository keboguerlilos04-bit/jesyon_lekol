import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/student.dart';
import '../../core/services/providers.dart';
import '../shared/assignments_list_view.dart';
import '../shared/attendance_summary_view.dart';
import '../shared/grades_report_view.dart';
import '../shared/payment_summary_view.dart';

/// Everything a parent can see about one of their children: report card,
/// attendance history, upcoming assignments, and the fee balance. Reached
/// by tapping a child in ParentHomeScreen's list — not deep-linked, same
/// choice made for the admin/teacher tab shells.
class ChildDetailScreen extends ConsumerWidget {
  const ChildDetailScreen({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeYearAsync = ref.watch(activeSchoolYearProvider);

    return activeYearAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(student.fullName)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(student.fullName)),
        body: Center(child: Text('Erè: $e')),
      ),
      data: (year) {
        if (year == null) {
          return Scaffold(
            appBar: AppBar(title: Text(student.fullName)),
            body: const Center(child: Text('Pa gen ane lekòl aktif kounye a.')),
          );
        }
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text(student.fullName),
              bottom: const TabBar(tabs: [
                Tab(text: 'Bilten'),
                Tab(text: 'Prezans'),
                Tab(text: 'Devwa'),
                Tab(text: 'Frè'),
              ]),
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
                PaymentSummaryView(studentId: student.id, yearId: year.id),
              ],
            ),
          ),
        );
      },
    );
  }
}
