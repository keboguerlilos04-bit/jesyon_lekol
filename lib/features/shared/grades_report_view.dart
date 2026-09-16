import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/models/class_model.dart';
import '../../core/models/grade.dart';
import '../../core/models/subject.dart';
import '../../core/services/grade_calculator.dart';
import '../../core/services/providers.dart';
import '../../core/services/report_card_pdf.dart';

const _terms = ['T1', 'T2', 'T3'];
const _schoolName = 'Jesyon Lekòl';

/// Read-only report card (bilten) for one student: a term switcher over a
/// per-subject breakdown of every graded evaluation, plus a coefficient-
/// weighted overall average for that term. Used by both the parent (viewing
/// a chosen child) and the student (viewing themselves).
class GradesReportView extends ConsumerStatefulWidget {
  const GradesReportView({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.yearId,
    required this.yearLabel,
  });

  final String studentId;
  final String studentName;
  final String classId;
  final String yearId;
  final String yearLabel;

  @override
  ConsumerState<GradesReportView> createState() => _GradesReportViewState();
}

class _GradesReportViewState extends ConsumerState<GradesReportView> {
  String _term = _terms.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<String>(
            segments: _terms.map((t) => ButtonSegment(value: t, label: Text(t))).toList(),
            selected: {_term},
            onSelectionChanged: (s) => setState(() => _term = s.first),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<List<ClassModel>>(
            stream: ref.watch(firestoreServiceProvider).watchClassesByIds([widget.classId]),
            builder: (context, classSnap) {
              final className = classSnap.data?.isNotEmpty == true ? classSnap.data!.first.name : '';
              return StreamBuilder<List<Subject>>(
                stream: ref.watch(firestoreServiceProvider).watchSubjects(classId: widget.classId),
                builder: (context, subjectSnap) {
                  final subjects = subjectSnap.data ?? const <Subject>[];
                  return StreamBuilder<List<Grade>>(
                    stream: ref.watch(firestoreServiceProvider).watchGradesForStudent(
                          widget.studentId,
                          yearId: widget.yearId,
                          term: _term,
                        ),
                    builder: (context, gradeSnap) {
                      if (!subjectSnap.hasData || !gradeSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final grades = gradeSnap.data!;
                      final summaries = subjects
                          .map((s) => SubjectTermSummary(
                                subjectId: s.id,
                                subjectName: s.name,
                                coefficient: s.coefficient,
                                entries: grades.where((g) => g.subjectId == s.id).toList(),
                              ))
                          .toList();
                      final overall = weightedTermAverage(summaries);

                      return Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: TextButton.icon(
                                onPressed: subjectSnap.hasData && gradeSnap.hasData
                                    ? () => Printing.layoutPdf(
                                          onLayout: (format) => buildReportCardPdf(
                                            schoolName: _schoolName,
                                            studentName: widget.studentName,
                                            className: className,
                                            yearLabel: widget.yearLabel,
                                            term: _term,
                                            subjects: summaries,
                                            overallAverage: overall,
                                          ),
                                        )
                                    : null,
                                icon: const Icon(Icons.picture_as_pdf_outlined),
                                label: const Text('Ekspòte Bilten PDF'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: summaries.length,
                              itemBuilder: (context, i) {
                                final s = summaries[i];
                                return ListTile(
                                  title: Text(s.subjectName),
                                  subtitle: s.entries.isEmpty
                                      ? const Text('Poko gen nòt')
                                      : Text(s.entries
                                          .map((g) => '${g.type.value}: ${g.value.toStringAsFixed(0)}/${g.maxValue.toStringAsFixed(0)}')
                                          .join(' • ')),
                                  trailing: s.average != null
                                      ? Text('${s.average!.toStringAsFixed(1)}/100',
                                          style: const TextStyle(fontWeight: FontWeight.bold))
                                      : null,
                                );
                              },
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Text(
                              overall != null
                                  ? 'Mwayèn Jeneral ($_term): ${overall.toStringAsFixed(1)}/100'
                                  : 'Poko gen nòt pou $_term',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
