import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/providers.dart';
import 'classes_screen.dart';
import 'enrollment_requests_screen.dart';
import 'finance_screen.dart';
import 'school_years_screen.dart';
import 'staff_screen.dart';
import 'subjects_screen.dart';

class _AdminSection {
  const _AdminSection(this.label, this.icon, this.screen);
  final String label;
  final IconData icon;
  final Widget screen;
}

final _sections = [
  _AdminSection('Ane Lekòl', Icons.calendar_today, const SchoolYearsScreen()),
  _AdminSection('Klas', Icons.class_outlined, const ClassesScreen()),
  _AdminSection('Matyè', Icons.menu_book_outlined, const SubjectsScreen()),
  _AdminSection('Anplwaye', Icons.people_outline, const StaffScreen()),
  _AdminSection('Enskripsyon', Icons.how_to_reg_outlined, const EnrollmentRequestsScreen()),
  _AdminSection('Finans', Icons.payments_outlined, const FinanceScreen()),
];

/// Admin dashboard shell: a role-scoped tab switcher (not deep-linked —
/// acceptable for an internal back-office section) between the five admin
/// modules. Every write these screens perform is still enforced server-side
/// by firestore.rules regardless of what this UI allows the admin to click.
class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final current = _sections[_index];

    final body = current.screen;

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
            Expanded(child: body),
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
      body: body,
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
