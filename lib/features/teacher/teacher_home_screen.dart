import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/providers.dart';
import 'attendance_screen.dart';
import 'grades_entry_screen.dart';
import 'teacher_assignments_screen.dart';
import 'teacher_messages_screen.dart';

class _TeacherSection {
  const _TeacherSection(this.label, this.icon, this.screen);
  final String label;
  final IconData icon;
  final Widget screen;
}

final _sections = [
  _TeacherSection('Nòt', Icons.grade_outlined, const GradesEntryScreen()),
  _TeacherSection('Prezans', Icons.fact_check_outlined, const AttendanceScreen()),
  _TeacherSection('Devwa', Icons.assignment_outlined, const TeacherAssignmentsScreen()),
  _TeacherSection('Mesaj', Icons.mail_outline, const TeacherMessagesScreen()),
];

/// Teacher dashboard shell. Every write these screens perform (grades,
/// attendance, assignments, messages) is still bound by firestore.rules to
/// this teacher's own uid regardless of what the UI lets them click.
class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final current = _sections[_index];

    if (isWide) {
      return Scaffold(
        appBar: AppBar(
          title: Text(current.label),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authServiceProvider).signOut(),
            ),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final s in _sections)
                  NavigationRailDestination(icon: Icon(s.icon), label: Text(s.label)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: current.screen),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(current.label),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: current.screen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final s in _sections) NavigationDestination(icon: Icon(s.icon), label: s.label),
        ],
      ),
    );
  }
}
