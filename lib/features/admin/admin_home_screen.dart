import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import '../shared/my_profile_screen.dart';
import 'classes_screen.dart';
import 'enrollment_requests_screen.dart';
import 'finance_screen.dart';
import 'profile_change_requests_screen.dart';
import 'school_years_screen.dart';
import 'staff_screen.dart';
import 'subjects_screen.dart';

class _AdminSection {
  const _AdminSection(this.label, this.icon, this.screen);
  final String label;
  final IconData icon;
  final Widget screen;
}

List<_AdminSection> _sections(AppLocalizations l10n) => [
      _AdminSection(l10n.navSchoolYears, Icons.calendar_today, const SchoolYearsScreen()),
      _AdminSection(l10n.classLabel, Icons.class_outlined, const ClassesScreen()),
      _AdminSection(l10n.navSubjects, Icons.menu_book_outlined, const SubjectsScreen()),
      _AdminSection(l10n.navStaff, Icons.people_outline, const StaffScreen()),
      _AdminSection(l10n.navEnrollment, Icons.how_to_reg_outlined, const EnrollmentRequestsScreen()),
      _AdminSection(l10n.navFinance, Icons.payments_outlined, const FinanceScreen()),
      _AdminSection(l10n.navChangeRequests, Icons.edit_note_outlined, const ProfileChangeRequestsScreen()),
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
    final sections = _sections(AppLocalizations.of(context)!);
    final current = sections[_index];

    final body = current.screen;

    if (isWide) {
      return Scaffold(
        appBar: AppBar(
          title: Text(current.label),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: AppLocalizations.of(context)!.myProfileTitle,
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
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final s in sections)
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
            icon: const Icon(Icons.person_outline),
            tooltip: AppLocalizations.of(context)!.myProfileTitle,
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
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final s in sections) NavigationDestination(icon: Icon(s.icon), label: s.label),
        ],
      ),
    );
  }
}
