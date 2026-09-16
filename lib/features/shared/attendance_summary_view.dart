import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/attendance_record.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import 'async_error_view.dart';

Map<AttendanceStatus, String> _statusLabels(AppLocalizations l10n) => {
      AttendanceStatus.present: l10n.statusPresent,
      AttendanceStatus.absent: l10n.statusAbsent,
      AttendanceStatus.late: l10n.statusLate,
      AttendanceStatus.excused: l10n.statusExcused,
    };

const _statusColors = {
  AttendanceStatus.present: Colors.green,
  AttendanceStatus.absent: Colors.red,
  AttendanceStatus.late: Colors.orange,
  AttendanceStatus.excused: Colors.blueGrey,
};

/// Read-only attendance history for one student: a summary row of counts by
/// status, then the underlying records newest-first.
class AttendanceSummaryView extends ConsumerWidget {
  const AttendanceSummaryView({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final l10n = AppLocalizations.of(context)!;
    final statusLabels = _statusLabels(l10n);
    return StreamBuilder<List<AttendanceRecord>>(
      stream: ref.watch(firestoreServiceProvider).watchAttendanceForStudent(studentId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return AsyncErrorView(error: snapshot.error);
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final records = List.of(snapshot.data!)..sort((a, b) => b.date.compareTo(a.date));
        if (records.isEmpty) {
          return Center(child: Text(l10n.noAttendanceRecords));
        }
        final counts = {for (final s in AttendanceStatus.values) s: 0};
        for (final r in records) {
          counts[r.status] = (counts[r.status] ?? 0) + 1;
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  for (final entry in counts.entries)
                    Chip(
                      avatar: CircleAvatar(backgroundColor: _statusColors[entry.key]),
                      label: Text(l10n.statusCountLabel(statusLabels[entry.key]!, entry.value)),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, i) {
                  final r = records[i];
                  return ListTile(
                    leading: Icon(Icons.circle, size: 12, color: _statusColors[r.status]),
                    title: Text(dateFormat.format(r.date)),
                    trailing: Text(statusLabels[r.status]!),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
