import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/attendance_record.dart';
import '../../core/models/class_model.dart';
import '../../core/models/student.dart';
import '../../core/services/providers.dart';

const _statusLabels = {
  AttendanceStatus.present: 'Prezan',
  AttendanceStatus.absent: 'Absan',
  AttendanceStatus.late: 'An reta',
  AttendanceStatus.excused: 'Eskize',
};

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String? _classId;
  DateTime _date = DateTime.now();
  final Map<String, AttendanceStatus> _statuses = {};
  bool _saving = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _statuses.clear();
      });
    }
  }

  Future<void> _submit(String classId, List<Student> roster) async {
    final teacherUid = ref.read(firebaseAuthProvider).currentUser!.uid;
    final service = ref.read(firestoreServiceProvider);
    final records = roster
        .map((s) => AttendanceRecord(
              id: service.attendanceDocId(classId: classId, studentId: s.id, date: _date),
              studentId: s.id,
              classId: classId,
              date: _date,
              status: _statuses[s.id] ?? AttendanceStatus.present,
              recordedBy: teacherUid,
            ))
        .toList();

    setState(() => _saving = true);
    try {
      await service.recordAttendanceBatch(records);

      final absentStudents = roster.where(
        (s) => (_statuses[s.id] ?? AttendanceStatus.present) == AttendanceStatus.absent,
      );
      for (final student in absentStudents) {
        final recipients = <String>{...student.parentIds, if (student.uid != null) student.uid!};
        await service.createAbsenceNotifications(
          recipientUids: recipients.toList(),
          studentName: student.fullName,
          date: _date,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Prezans anrejistre pou ${records.length} elèv.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherProfileAsync = ref.watch(currentTeacherProfileProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return teacherProfileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erè: $e')),
      data: (profile) {
        if (profile == null || profile.classIds.isEmpty) {
          return const Center(child: Text('Ou poko gen klas ki asiyen a ou.'));
        }
        return StreamBuilder<List<ClassModel>>(
          stream: ref.watch(firestoreServiceProvider).watchClassesByIds(profile.classIds),
          builder: (context, classSnap) {
            final classes = classSnap.data ?? const [];
            _classId ??= classes.isEmpty ? null : classes.first.id;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          initialValue: _classId,
                          decoration: const InputDecoration(labelText: 'Klas'),
                          items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (v) => setState(() {
                            _classId = v;
                            _statuses.clear();
                          }),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(dateFormat.format(_date)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _classId == null
                      ? const Center(child: Text('Chwazi yon klas.'))
                      : _AttendanceRoster(
                          classId: _classId!,
                          date: _date,
                          statuses: _statuses,
                          onSubmit: (roster) => _submit(_classId!, roster),
                          saving: _saving,
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AttendanceRoster extends ConsumerStatefulWidget {
  const _AttendanceRoster({
    required this.classId,
    required this.date,
    required this.statuses,
    required this.onSubmit,
    required this.saving,
  });

  final String classId;
  final DateTime date;
  final Map<String, AttendanceStatus> statuses;
  final Future<void> Function(List<Student> roster) onSubmit;
  final bool saving;

  @override
  ConsumerState<_AttendanceRoster> createState() => _AttendanceRosterState();
}

class _AttendanceRosterState extends ConsumerState<_AttendanceRoster> {
  String get classId => widget.classId;
  DateTime get date => widget.date;
  Map<String, AttendanceStatus> get statuses => widget.statuses;
  Future<void> Function(List<Student> roster) get onSubmit => widget.onSubmit;
  bool get saving => widget.saving;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Student>>(
      stream: ref.watch(firestoreServiceProvider).watchStudentsByClass(classId),
      builder: (context, rosterSnap) {
        if (!rosterSnap.hasData) return const Center(child: CircularProgressIndicator());
        final roster = rosterSnap.data!;
        if (roster.isEmpty) return const Center(child: Text('Pa gen elèv nan klas sa a.'));

        return StreamBuilder<List<AttendanceRecord>>(
          stream: ref.watch(firestoreServiceProvider).watchAttendanceForClassDate(classId, date),
          builder: (context, attendanceSnap) {
            for (final r in attendanceSnap.data ?? const <AttendanceRecord>[]) {
              statuses.putIfAbsent(r.studentId, () => r.status);
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: roster.length,
                    itemBuilder: (context, i) {
                      final student = roster[i];
                      final status = statuses[student.id] ?? AttendanceStatus.present;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(student.fullName)),
                            DropdownButton<AttendanceStatus>(
                              value: status,
                              items: AttendanceStatus.values
                                  .map((s) => DropdownMenuItem(value: s, child: Text(_statusLabels[s]!)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => statuses[student.id] = v);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: saving ? null : () => onSubmit(roster),
                      child: saving
                          ? const SizedBox(
                              height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Anrejistre Prezans'),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
