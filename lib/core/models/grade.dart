import 'package:cloud_firestore/cloud_firestore.dart';

enum EvaluationType { devwa, egzamen, kontwol }

extension EvaluationTypeX on EvaluationType {
  String get value => name;

  static EvaluationType fromString(String value) {
    return EvaluationType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => EvaluationType.devwa,
    );
  }
}

/// Mirrors a document in /grades/{gradeId}.
/// Only Cloud Functions / a teacher who owns [teacherUid] may write here —
/// enforced in Firestore Security Rules, never in the client.
class Grade {
  final String id;
  final String studentId;
  final String subjectId;
  final String classId;
  final String yearId;
  final String teacherUid;
  final String term; // "T1" | "T2" | "T3"
  final EvaluationType type;
  final double value;
  final double maxValue;
  final DateTime? createdAt;

  const Grade({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.classId,
    required this.yearId,
    required this.teacherUid,
    required this.term,
    required this.type,
    required this.value,
    required this.maxValue,
    this.createdAt,
  });

  factory Grade.fromMap(String id, Map<String, dynamic> map) {
    return Grade(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      subjectId: map['subjectId'] as String? ?? '',
      classId: map['classId'] as String? ?? '',
      yearId: map['yearId'] as String? ?? '',
      teacherUid: map['teacherUid'] as String? ?? '',
      term: map['term'] as String? ?? 'T1',
      type: EvaluationTypeX.fromString(map['type'] as String? ?? 'devwa'),
      value: (map['value'] as num?)?.toDouble() ?? 0,
      maxValue: (map['maxValue'] as num?)?.toDouble() ?? 100,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'subjectId': subjectId,
      'classId': classId,
      'yearId': yearId,
      'teacherUid': teacherUid,
      'term': term,
      'type': type.value,
      'value': value,
      'maxValue': maxValue,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
