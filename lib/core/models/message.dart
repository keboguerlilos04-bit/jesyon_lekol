import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors a document in /messages/{messageId}.
/// Addressed to a specific student's file rather than one inbox: at send
/// time the client resolves [recipientUids] to that student's parent(s) and
/// their own account (if they have one), so a message always reaches every
/// guardian on file without the sender needing to know who they are.
class Message {
  final String id;
  final String fromUid;
  final String studentId;
  final String classId;
  final String? subjectId;
  final List<String> recipientUids;
  final String title;
  final String body;
  final DateTime? sentAt;

  const Message({
    required this.id,
    required this.fromUid,
    required this.studentId,
    required this.classId,
    required this.recipientUids,
    required this.title,
    required this.body,
    this.subjectId,
    this.sentAt,
  });

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      fromUid: map['fromUid'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      classId: map['classId'] as String? ?? '',
      subjectId: map['subjectId'] as String?,
      recipientUids: List<String>.from(map['recipientUids'] as List? ?? const []),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      sentAt: (map['sentAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUid': fromUid,
      'studentId': studentId,
      'classId': classId,
      'subjectId': subjectId,
      'recipientUids': recipientUids,
      'title': title,
      'body': body,
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : FieldValue.serverTimestamp(),
    };
  }
}
