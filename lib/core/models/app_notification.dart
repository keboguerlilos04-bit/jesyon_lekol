import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { absence, grade, payment, announcement }

extension NotificationTypeX on NotificationType {
  String get value => name;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => NotificationType.announcement,
    );
  }
}

/// Mirrors a document in /notifications/{id}. One document per recipient —
/// see FirestoreService.createAbsenceNotifications for how a single event
/// (a student marked absent) fans out to every parent + the student.
class AppNotification {
  final String id;
  final String toUid;
  final NotificationType type;
  final String title;
  final String body;
  final bool seen;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.toUid,
    required this.type,
    required this.title,
    required this.body,
    this.seen = false,
    this.createdAt,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      toUid: map['toUid'] as String? ?? '',
      type: NotificationTypeX.fromString(map['type'] as String? ?? 'announcement'),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      seen: map['seen'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toUid': toUid,
      'type': type.value,
      'title': title,
      'body': body,
      'seen': seen,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
