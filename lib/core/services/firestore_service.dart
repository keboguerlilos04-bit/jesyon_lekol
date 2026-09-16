import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/assignment.dart';
import '../models/attendance_record.dart';
import '../models/class_model.dart';
import '../models/enrollment_request.dart';
import '../models/grade.dart';
import '../models/message.dart';
import '../models/payment_record.dart';
import '../models/school_year.dart';
import '../models/student.dart';
import '../models/subject.dart';
import '../models/teacher_profile.dart';
import '../models/user_role.dart';

/// yyyy-MM-dd, used as part of deterministic attendance document ids so
/// re-submitting the same day's roll call updates it instead of duplicating.
String dateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Read-oriented Firestore access. Writes to grades/attendance/payments are
/// intentionally NOT exposed generically here: each write goes through a
/// purpose-specific method (or a Cloud Function) so the call site can never
/// "accidentally" write a document a role shouldn't be able to touch —
/// Security Rules are the real enforcement, this is defense in depth.
class FirestoreService {
  FirestoreService(this._db);

  final FirebaseFirestore _db;

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Stream<Student?> watchStudent(String studentId) {
    return _db.collection('students').doc(studentId).snapshots().map(
          (doc) => doc.exists ? Student.fromMap(doc.id, doc.data()!) : null,
        );
  }

  Stream<List<Student>> watchStudentsByIds(List<String> studentIds) {
    if (studentIds.isEmpty) return Stream.value(const []);
    return _db
        .collection('students')
        .where(FieldPath.documentId, whereIn: studentIds)
        .snapshots()
        .map((s) => s.docs.map((d) => Student.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Grade>> watchGradesForStudent(
    String studentId, {
    required String yearId,
    String? term,
  }) {
    Query<Map<String, dynamic>> q = _db
        .collection('grades')
        .where('studentId', isEqualTo: studentId)
        .where('yearId', isEqualTo: yearId);
    if (term != null) q = q.where('term', isEqualTo: term);
    return q.snapshots().map(
          (s) => s.docs.map((d) => Grade.fromMap(d.id, d.data())).toList(),
        );
  }

  /// Only callable successfully by a teacher who owns [grade.teacherUid],
  /// or an admin — enforced in firestore.rules.
  Future<void> submitGrade(Grade grade) {
    return _db.collection('grades').doc(grade.id).set(grade.toMap());
  }

  Stream<List<AttendanceRecord>> watchAttendanceForStudent(
    String studentId, {
    DateTime? from,
    DateTime? to,
  }) {
    Query<Map<String, dynamic>> q =
        _db.collection('attendance').where('studentId', isEqualTo: studentId);
    if (from != null) q = q.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    if (to != null) q = q.where('date', isLessThanOrEqualTo: Timestamp.fromDate(to));
    return q.snapshots().map(
          (s) => s.docs.map((d) => AttendanceRecord.fromMap(d.id, d.data())).toList(),
        );
  }

  /// Only callable by the teacher recording it, or an admin.
  Future<void> recordAttendance(AttendanceRecord record) {
    return _db.collection('attendance').doc(record.id).set(record.toMap());
  }

  String paymentDocId({required String studentId, required String yearId}) => '${studentId}_$yearId';

  Stream<PaymentRecord?> watchPayment(String studentId, String yearId) {
    return _db
        .collection('payments')
        .doc(paymentDocId(studentId: studentId, yearId: yearId))
        .snapshots()
        .map((doc) => doc.exists ? PaymentRecord.fromMap(doc.id, doc.data()!) : null);
  }

  // ---------------------------------------------------------------------
  // Admin module: school years, classes, subjects, staff, enrollment.
  // All writes here are gated to role == 'admin' in firestore.rules.
  // ---------------------------------------------------------------------

  Stream<List<SchoolYear>> watchSchoolYears() {
    return _db.collection('schoolYears').orderBy('startDate', descending: true).snapshots().map(
          (s) => s.docs.map((d) => SchoolYear.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> saveSchoolYear(SchoolYear year) {
    return _db.collection('schoolYears').doc(year.id).set(year.toMap());
  }

  /// Marks [yearId] active and deactivates every other school year in the
  /// same batch so exactly one year is ever active at a time.
  Future<void> setActiveSchoolYear(String yearId) async {
    final batch = _db.batch();
    final snapshot = await _db.collection('schoolYears').get();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'active': doc.id == yearId});
    }
    await batch.commit();
  }

  Future<void> deleteSchoolYear(String yearId) {
    return _db.collection('schoolYears').doc(yearId).delete();
  }

  Stream<List<ClassModel>> watchClasses({String? yearId}) {
    Query<Map<String, dynamic>> q = _db.collection('classes');
    if (yearId != null) q = q.where('yearId', isEqualTo: yearId);
    return q.orderBy('name').snapshots().map(
          (s) => s.docs.map((d) => ClassModel.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> saveClass(ClassModel classModel) {
    return _db.collection('classes').doc(classModel.id).set(classModel.toMap());
  }

  Future<void> deleteClass(String classId) {
    return _db.collection('classes').doc(classId).delete();
  }

  Stream<List<Subject>> watchSubjects({String? classId}) {
    Query<Map<String, dynamic>> q = _db.collection('subjects');
    if (classId != null) q = q.where('classId', isEqualTo: classId);
    return q.orderBy('name').snapshots().map(
          (s) => s.docs.map((d) => Subject.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> saveSubject(Subject subject) {
    return _db.collection('subjects').doc(subject.id).set(subject.toMap());
  }

  Future<void> deleteSubject(String subjectId) {
    return _db.collection('subjects').doc(subjectId).delete();
  }

  /// Employees only (teacher/admin `role`) — parents/students are excluded.
  Stream<List<AppUser>> watchStaff() {
    return _db
        .collection('users')
        .where('role', whereIn: [UserRole.admin.value, UserRole.teacher.value])
        .orderBy('fullName')
        .snapshots()
        .map((s) => s.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList());
  }

  Stream<List<EnrollmentRequest>> watchEnrollmentRequests({EnrollmentRequestStatus? status}) {
    Query<Map<String, dynamic>> q = _db.collection('enrollmentRequests');
    if (status != null) q = q.where('status', isEqualTo: status.value);
    return q.orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map((d) => EnrollmentRequest.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> createEnrollmentRequest(EnrollmentRequest request) {
    return _db.collection('enrollmentRequests').doc(request.id).set(request.toMap());
  }

  Future<void> rejectEnrollmentRequest(String requestId) {
    return _db
        .collection('enrollmentRequests')
        .doc(requestId)
        .update({'status': EnrollmentRequestStatus.rejected.value});
  }

  // ---------------------------------------------------------------------
  // Teacher module: roster, grade entry, attendance, assignments, messages.
  // ---------------------------------------------------------------------

  Future<TeacherProfile?> getTeacherProfile(String uid) async {
    final doc = await _db.collection('teachers').doc(uid).get();
    if (!doc.exists) return null;
    return TeacherProfile.fromMap(doc.id, doc.data()!);
  }

  Stream<List<ClassModel>> watchClassesByIds(List<String> classIds) {
    if (classIds.isEmpty) return Stream.value(const []);
    return _db
        .collection('classes')
        .where(FieldPath.documentId, whereIn: classIds)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => ClassModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Subject>> watchSubjectsByIds(List<String> subjectIds) {
    if (subjectIds.isEmpty) return Stream.value(const []);
    return _db
        .collection('subjects')
        .where(FieldPath.documentId, whereIn: subjectIds)
        .snapshots()
        .map((s) => s.docs.map((d) => Subject.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Student>> watchStudentsByClass(String classId) {
    return _db
        .collection('students')
        .where('classId', isEqualTo: classId)
        .orderBy('lastName')
        .snapshots()
        .map((s) => s.docs.map((d) => Student.fromMap(d.id, d.data())).toList());
  }

  /// One grade slot per student/subject/term/type — re-submitting overwrites
  /// rather than accumulating separate entries. Good enough for "the T1
  /// devwa grade" style report cards; a school wanting several graded devwa
  /// per term should give each its own `type` label (e.g. "devwa1").
  String gradeDocId({
    required String studentId,
    required String subjectId,
    required String yearId,
    required String term,
    required String type,
  }) =>
      '${studentId}_${subjectId}_${yearId}_${term}_$type';

  Stream<List<Grade>> watchGradesForEvaluation({
    required String classId,
    required String subjectId,
    required String yearId,
    required String term,
    required String type,
  }) {
    return _db
        .collection('grades')
        .where('classId', isEqualTo: classId)
        .where('subjectId', isEqualTo: subjectId)
        .where('yearId', isEqualTo: yearId)
        .where('term', isEqualTo: term)
        .where('type', isEqualTo: type)
        .snapshots()
        .map((s) => s.docs.map((d) => Grade.fromMap(d.id, d.data())).toList());
  }

  /// Upserts every grade in one batch. Each [grade.id] should come from
  /// [gradeDocId] so re-submitting the same evaluation overwrites cleanly.
  Future<void> submitGradesBatch(List<Grade> grades) async {
    final batch = _db.batch();
    for (final grade in grades) {
      batch.set(_db.collection('grades').doc(grade.id), grade.toMap());
    }
    await batch.commit();
  }

  String attendanceDocId({required String classId, required String studentId, required DateTime date}) =>
      '${classId}_${studentId}_${dateKey(date)}';

  Stream<List<AttendanceRecord>> watchAttendanceForClassDate(String classId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _db
        .collection('attendance')
        .where('classId', isEqualTo: classId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) => s.docs.map((d) => AttendanceRecord.fromMap(d.id, d.data())).toList());
  }

  /// Upserts a whole day's roll call for a class in one batch. Each
  /// [records] entry's id should come from [attendanceDocId].
  Future<void> recordAttendanceBatch(List<AttendanceRecord> records) async {
    final batch = _db.batch();
    for (final record in records) {
      batch.set(_db.collection('attendance').doc(record.id), record.toMap());
    }
    await batch.commit();
  }

  Stream<List<Assignment>> watchAssignmentsByTeacher(String teacherUid) {
    return _db
        .collection('assignments')
        .where('teacherUid', isEqualTo: teacherUid)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Assignment.fromMap(d.id, d.data())).toList());
  }

  Future<void> createAssignment(Assignment assignment) {
    return _db.collection('assignments').doc(assignment.id).set(assignment.toMap());
  }

  Future<void> deleteAssignment(String assignmentId) {
    return _db.collection('assignments').doc(assignmentId).delete();
  }

  Stream<List<Message>> watchSentMessages(String teacherUid) {
    return _db
        .collection('messages')
        .where('fromUid', isEqualTo: teacherUid)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Message.fromMap(d.id, d.data())).toList());
  }

  Future<void> sendMessage(Message message) {
    return _db.collection('messages').doc(message.id).set(message.toMap());
  }

  Stream<List<Assignment>> watchAssignmentsByClass(String classId) {
    return _db
        .collection('assignments')
        .where('classId', isEqualTo: classId)
        .orderBy('dueDate')
        .snapshots()
        .map((s) => s.docs.map((d) => Assignment.fromMap(d.id, d.data())).toList());
  }

  /// One notification per recipient (a student's parents + the student's own
  /// account, if any) so each person's unread state is independent.
  Future<void> createAbsenceNotifications({
    required List<String> recipientUids,
    required String studentName,
    required DateTime date,
  }) async {
    if (recipientUids.isEmpty) return;
    final batch = _db.batch();
    for (final uid in recipientUids) {
      final ref = _db.collection('notifications').doc();
      batch.set(
        ref,
        AppNotification(
          id: ref.id,
          toUid: uid,
          type: NotificationType.absence,
          title: 'Absans',
          body: '$studentName te make absan(t) jodi a (${dateKey(date)}).',
        ).toMap(),
      );
    }
    await batch.commit();
  }

  // ---------------------------------------------------------------------
  // Parent/Student module: reads scoped to their own studentIds by
  // firestore.rules regardless of what this client asks for.
  // ---------------------------------------------------------------------

  Stream<List<AppNotification>> watchNotifications(String uid) {
    return _db
        .collection('notifications')
        .where('toUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AppNotification.fromMap(d.id, d.data())).toList());
  }

  Future<void> markNotificationSeen(String notificationId) {
    return _db.collection('notifications').doc(notificationId).update({'seen': true});
  }

  // ---------------------------------------------------------------------
  // Finance module (admin-only writes; see firestore.rules on /payments).
  // ---------------------------------------------------------------------

  Stream<List<Student>> watchAllStudents() {
    return _db.collection('students').orderBy('lastName').snapshots().map(
          (s) => s.docs.map((d) => Student.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<PaymentRecord>> watchPaymentsForYear(String yearId) {
    return _db.collection('payments').where('yearId', isEqualTo: yearId).snapshots().map(
          (s) => s.docs.map((d) => PaymentRecord.fromMap(d.id, d.data())).toList(),
        );
  }

  /// Creates the payment record for a student/year if it doesn't exist yet,
  /// or updates just the total owed if it does — never touches the
  /// installments already on file.
  Future<void> setPaymentTotalDue({
    required String studentId,
    required String yearId,
    required double totalDue,
    required String updatedBy,
  }) {
    final id = paymentDocId(studentId: studentId, yearId: yearId);
    return _db.collection('payments').doc(id).set({
      'studentId': studentId,
      'yearId': yearId,
      'totalDue': totalDue,
      'updatedBy': updatedBy,
    }, SetOptions(merge: true));
  }

  /// Appends one received payment and recomputes the running total inside a
  /// transaction, so two people recording a payment for the same student at
  /// the same time can't silently drop one of them.
  Future<PaymentRecord> recordPaymentInstallment({
    required String studentId,
    required String yearId,
    required Installment installment,
    required String updatedBy,
  }) {
    final id = paymentDocId(studentId: studentId, yearId: yearId);
    final ref = _db.collection('payments').doc(id);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = snap.exists
          ? PaymentRecord.fromMap(id, snap.data()!)
          : PaymentRecord(
              id: id,
              studentId: studentId,
              yearId: yearId,
              totalDue: 0,
              amountPaid: 0,
              installments: const [],
              updatedBy: updatedBy,
            );
      final updated = PaymentRecord(
        id: id,
        studentId: studentId,
        yearId: yearId,
        totalDue: current.totalDue,
        amountPaid: current.amountPaid + installment.amount,
        installments: [...current.installments, installment],
        updatedBy: updatedBy,
      );
      tx.set(ref, updated.toMap());
      return updated;
    });
  }
}
