import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/class_model.dart';
import '../../core/models/grade.dart';
import '../../core/models/student.dart';
import '../../core/models/subject.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import '../shared/async_error_view.dart';

const _terms = ['T1', 'T2', 'T3'];
const _types = ['devwa', 'egzamen', 'kontwol'];

/// Grade entry for one class/subject/term/evaluation-type at a time. Each
/// student gets exactly one editable value for that combination — see
/// FirestoreService.gradeDocId for why multiple "devwa" in the same term
/// need their own `type` label rather than being entered here.
class GradesEntryScreen extends ConsumerStatefulWidget {
  const GradesEntryScreen({super.key});

  @override
  ConsumerState<GradesEntryScreen> createState() => _GradesEntryScreenState();
}

class _GradesEntryScreenState extends ConsumerState<GradesEntryScreen> {
  String? _classId;
  String? _subjectId;
  String _term = _terms.first;
  String _type = _types.first;
  final _maxValueController = TextEditingController(text: '100');
  final Map<String, TextEditingController> _valueControllers = {};
  bool _saving = false;

  @override
  void dispose() {
    _maxValueController.dispose();
    for (final c in _valueControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String studentId, double? existingValue) {
    return _valueControllers.putIfAbsent(
      studentId,
      () => TextEditingController(text: existingValue?.toString() ?? ''),
    );
  }

  Future<void> _submit({
    required String classId,
    required String subjectId,
    required String yearId,
    required List<Student> roster,
  }) async {
    final teacherUid = ref.read(firebaseAuthProvider).currentUser!.uid;
    final maxValue = double.tryParse(_maxValueController.text) ?? 100;
    final service = ref.read(firestoreServiceProvider);

    final grades = <Grade>[];
    for (final student in roster) {
      final text = _valueControllers[student.id]?.text.trim();
      if (text == null || text.isEmpty) continue;
      final value = double.tryParse(text);
      if (value == null) continue;
      grades.add(Grade(
        id: service.gradeDocId(
          studentId: student.id,
          subjectId: subjectId,
          yearId: yearId,
          term: _term,
          type: _type,
        ),
        studentId: student.id,
        subjectId: subjectId,
        classId: classId,
        yearId: yearId,
        teacherUid: teacherUid,
        term: _term,
        type: EvaluationTypeX.fromString(_type),
        value: value,
        maxValue: maxValue,
      ));
    }

    setState(() => _saving = true);
    try {
      await service.submitGradesBatch(grades);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.gradesRecorded(grades.length))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherProfileAsync = ref.watch(currentTeacherProfileProvider);
    final activeYearAsync = ref.watch(activeSchoolYearProvider);
    final l10n = AppLocalizations.of(context)!;

    return teacherProfileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.errorPrefix(e))),
      data: (profile) {
        if (profile == null || profile.classIds.isEmpty) {
          return Center(child: Text(l10n.noAssignedClasses));
        }
        return activeYearAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.errorPrefix(e))),
          data: (year) {
            if (year == null) {
              return Center(child: Text(l10n.noActiveSchoolYear));
            }
            return StreamBuilder<List<ClassModel>>(
              stream: ref.watch(firestoreServiceProvider).watchClassesByIds(profile.classIds),
              builder: (context, classSnap) {
                final classes = classSnap.data ?? const [];
                _classId ??= classes.isEmpty ? null : classes.first.id;
                return StreamBuilder<List<Subject>>(
                  stream: ref.watch(firestoreServiceProvider).watchSubjectsByIds(profile.subjectIds),
                  builder: (context, subjectSnap) {
                    final subjectsForClass = (subjectSnap.data ?? const [])
                        .where((s) => s.classId == _classId)
                        .toList();
                    if (_subjectId == null || !subjectsForClass.any((s) => s.id == _subjectId)) {
                      _subjectId = subjectsForClass.isEmpty ? null : subjectsForClass.first.id;
                    }

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
                                  decoration: InputDecoration(labelText: l10n.classLabel),
                                  items: classes
                                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                                      .toList(),
                                  onChanged: (v) => setState(() {
                                    _classId = v;
                                    _valueControllers.clear();
                                  }),
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _subjectId,
                                  decoration: InputDecoration(labelText: l10n.navSubjects),
                                  items: subjectsForClass
                                      .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                                      .toList(),
                                  onChanged: (v) => setState(() {
                                    _subjectId = v;
                                    _valueControllers.clear();
                                  }),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _term,
                                  decoration: InputDecoration(labelText: l10n.termLabel),
                                  items: _terms.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                  onChanged: (v) => setState(() {
                                    _term = v!;
                                    _valueControllers.clear();
                                  }),
                                ),
                              ),
                              SizedBox(
                                width: 140,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _type,
                                  decoration: InputDecoration(labelText: l10n.typeLabel),
                                  items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                  onChanged: (v) => setState(() {
                                    _type = v!;
                                    _valueControllers.clear();
                                  }),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _maxValueController,
                                  decoration: InputDecoration(labelText: l10n.maxScoreField),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: _classId == null || _subjectId == null
                              ? Center(child: Text(l10n.chooseClassAndSubject))
                              : _RosterGrid(
                                  classId: _classId!,
                                  subjectId: _subjectId!,
                                  yearId: year.id,
                                  term: _term,
                                  type: _type,
                                  controllerFor: _controllerFor,
                                  onSubmit: (roster) => _submit(
                                    classId: _classId!,
                                    subjectId: _subjectId!,
                                    yearId: year.id,
                                    roster: roster,
                                  ),
                                  saving: _saving,
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _RosterGrid extends ConsumerWidget {
  const _RosterGrid({
    required this.classId,
    required this.subjectId,
    required this.yearId,
    required this.term,
    required this.type,
    required this.controllerFor,
    required this.onSubmit,
    required this.saving,
  });

  final String classId;
  final String subjectId;
  final String yearId;
  final String term;
  final String type;
  final TextEditingController Function(String studentId, double? existingValue) controllerFor;
  final Future<void> Function(List<Student> roster) onSubmit;
  final bool saving;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<Student>>(
      stream: ref.watch(firestoreServiceProvider).watchStudentsByClass(classId),
      builder: (context, rosterSnap) {
        if (rosterSnap.hasError) return AsyncErrorView(error: rosterSnap.error);
        if (!rosterSnap.hasData) return const Center(child: CircularProgressIndicator());
        final roster = rosterSnap.data!;
        if (roster.isEmpty) return Center(child: Text(l10n.noStudentsInClass));

        return StreamBuilder<List<Grade>>(
          stream: ref.watch(firestoreServiceProvider).watchGradesForEvaluation(
                classId: classId,
                subjectId: subjectId,
                yearId: yearId,
                term: term,
                type: type,
              ),
          builder: (context, gradesSnap) {
            final existingByStudent = {
              for (final g in gradesSnap.data ?? const <Grade>[]) g.studentId: g,
            };

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: roster.length,
                    itemBuilder: (context, i) {
                      final student = roster[i];
                      final controller =
                          controllerFor(student.id, existingByStudent[student.id]?.value);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(student.fullName)),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: controller,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(isDense: true, hintText: l10n.gradeHint),
                              ),
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
                          : Text(l10n.saveGradesButton),
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
