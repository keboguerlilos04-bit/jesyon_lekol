import '../models/grade.dart';

/// A subject's grades for one term, normalized to a /100 average.
class SubjectTermSummary {
  final String subjectId;
  final String subjectName;
  final double coefficient;
  final List<Grade> entries;

  const SubjectTermSummary({
    required this.subjectId,
    required this.subjectName,
    required this.coefficient,
    required this.entries,
  });

  /// Mean of each entry normalized to /100. Null when there is nothing
  /// graded yet for this subject/term — kept out of the term average rather
  /// than treated as a zero.
  double? get average {
    if (entries.isEmpty) return null;
    final sum = entries.fold<double>(0, (acc, g) => acc + (g.value / g.maxValue) * 100);
    return sum / entries.length;
  }
}

/// Coefficient-weighted average across every subject that has at least one
/// grade — subjects with nothing entered yet don't drag the average down.
double? weightedTermAverage(List<SubjectTermSummary> subjects) {
  final graded = subjects.where((s) => s.average != null).toList();
  if (graded.isEmpty) return null;
  final weightSum = graded.fold<double>(0, (acc, s) => acc + s.coefficient);
  if (weightSum == 0) return null;
  final weighted = graded.fold<double>(0, (acc, s) => acc + s.average! * s.coefficient);
  return weighted / weightSum;
}
