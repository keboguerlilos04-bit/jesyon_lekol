import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/assignment.dart';
import '../../core/services/providers.dart';

/// Read-only list of assignments/exams for one class, soonest due first —
/// serves as the "kalandriye devwa" for parents and students alike.
class AssignmentsListView extends ConsumerWidget {
  const AssignmentsListView({super.key, required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();
    return StreamBuilder<List<Assignment>>(
      stream: ref.watch(firestoreServiceProvider).watchAssignmentsByClass(classId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final assignments = snapshot.data!;
        if (assignments.isEmpty) {
          return const Center(child: Text('Pa gen devwa oswa egzamen pwograme.'));
        }
        return ListView.builder(
          itemCount: assignments.length,
          itemBuilder: (context, i) {
            final a = assignments[i];
            final overdue = a.dueDate.isBefore(DateTime(now.year, now.month, now.day));
            return ListTile(
              leading: Icon(
                Icons.event_note,
                color: overdue ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.primary,
              ),
              title: Text(a.title),
              subtitle: Text(a.description.isEmpty ? dateFormat.format(a.dueDate) : a.description),
              trailing: Text(
                dateFormat.format(a.dueDate),
                style: TextStyle(color: overdue ? Theme.of(context).disabledColor : null),
              ),
            );
          },
        );
      },
    );
  }
}
