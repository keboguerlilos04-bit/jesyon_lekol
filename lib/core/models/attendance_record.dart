import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { present, absent, late, excused }

extension AttendanceStatusX on AttendanceStatus {
  String get value => name;

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => AttendanceStatus.present,
    );
  }
}

/// Mirrors a document in /attendance/{attendanceId}.
class AttendanceRecord {
  final String id;
  final String studentId;
  final String classId;
  final DateTime date;
  final AttendanceStatus status;
  final String recordedBy; // teacherUid

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
    required this.status,
    required this.recordedBy,
  });

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceRecord(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      classId: map['classId'] as String? ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: AttendanceStatusX.fromString(map['status'] as String? ?? 'present'),
      recordedBy: map['recordedBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'classId': classId,
      'date': Timestamp.fromDate(date),
      'status': status.value,
      'recordedBy': recordedBy,
    };
  }
}
