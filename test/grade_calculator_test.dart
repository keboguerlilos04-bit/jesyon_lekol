import 'package:flutter_test/flutter_test.dart';
import 'package:jesyon_lekol/core/models/grade.dart';
import 'package:jesyon_lekol/core/services/grade_calculator.dart';

Grade _grade(double value, double maxValue) {
  return Grade(
    id: 'g',
    studentId: 's',
    subjectId: 'subj',
    classId: 'c',
    yearId: 'y',
    teacherUid: 't',
    term: 'T1',
    type: EvaluationType.devwa,
    value: value,
    maxValue: maxValue,
  );
}

SubjectTermSummary _summary(String id, double coefficient, List<Grade> entries) {
  return SubjectTermSummary(
    subjectId: id,
    subjectName: id,
    coefficient: coefficient,
    entries: entries,
  );
}

void main() {
  group('SubjectTermSummary.average', () {
    test('is null with no entries', () {
      expect(_summary('math', 3, []).average, isNull);
    });

    test('normalizes a single entry to /100', () {
      expect(_summary('math', 3, [_grade(8, 10)]).average, 80);
    });

    test('averages multiple entries, each normalized to /100 first', () {
      // 8/10 -> 80, 15/20 -> 75 => mean 77.5
      final s = _summary('math', 3, [_grade(8, 10), _grade(15, 20)]);
      expect(s.average, 77.5);
    });
  });

  group('weightedTermAverage', () {
    test('is null when there are no subjects', () {
      expect(weightedTermAverage([]), isNull);
    });

    test('is null when every subject is ungraded', () {
      final subjects = [_summary('math', 3, []), _summary('french', 2, [])];
      expect(weightedTermAverage(subjects), isNull);
    });

    test('ignores ungraded subjects rather than treating them as zero', () {
      final subjects = [
        _summary('math', 3, [_grade(100, 100)]),
        _summary('french', 5, []),
      ];
      expect(weightedTermAverage(subjects), 100);
    });

    test('weights graded subjects by coefficient', () {
      final subjects = [
        _summary('math', 3, [_grade(100, 100)]), // average 100, weight 3
        _summary('french', 1, [_grade(0, 100)]), // average 0, weight 1
      ];
      // (100*3 + 0*1) / (3+1) = 75
      expect(weightedTermAverage(subjects), 75);
    });

    test('is null when the graded subjects all have a zero coefficient', () {
      final subjects = [_summary('math', 0, [_grade(80, 100)])];
      expect(weightedTermAverage(subjects), isNull);
    });
  });
}
