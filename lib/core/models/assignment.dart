import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors a document in /assignments/{assignmentId}.
class Assignment {
  final String id;
  final String classId;
  final String subjectId;
  final String teacherUid;
  final String title;
  final String description;
  final DateTime dueDate;
  final String? attachmentUrl;

  const Assignment({
    required this.id,
    required this.classId,
    required this.subjectId,
    required this.teacherUid,
    required this.title,
    required this.description,
    required this.dueDate,
    this.attachmentUrl,
  });

  factory Assignment.fromMap(String id, Map<String, dynamic> map) {
    return Assignment(
      id: id,
      classId: map['classId'] as String? ?? '',
      subjectId: map['subjectId'] as String? ?? '',
      teacherUid: map['teacherUid'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      attachmentUrl: map['attachmentUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'subjectId': subjectId,
      'teacherUid': teacherUid,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'attachmentUrl': attachmentUrl,
    };
  }
}
