// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get required => 'Required';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get classLabel => 'Class';

  @override
  String errorPrefix(Object error) {
    return 'Error: $error';
  }

  @override
  String get appName => 'Jesyon Lekòl';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get loginButton => 'Log In';

  @override
  String get loginIncorrect => 'Incorrect email or password.';

  @override
  String get unauthorizedMessage => 'You don\'t have access to this page.';

  @override
  String get navSchoolYears => 'School Years';

  @override
  String get navSubjects => 'Subjects';

  @override
  String get navStaff => 'Staff';

  @override
  String get navEnrollment => 'Enrollment';

  @override
  String get navFinance => 'Finance';

  @override
  String get navGrades => 'Grades';

  @override
  String get navAttendance => 'Attendance';

  @override
  String get navAssignments => 'Assignments';

  @override
  String get navMessages => 'Messages';

  @override
  String get newSchoolYear => 'New School Year';

  @override
  String get editSchoolYear => 'Edit School Year';

  @override
  String get yearLabelField => 'Label (e.g. 2026-2027)';

  @override
  String get startDateLabel => 'Start';

  @override
  String get endDateLabel => 'End';

  @override
  String get noSchoolYears => 'No school years yet. Tap + to create one.';

  @override
  String get activate => 'Activate';

  @override
  String get newClass => 'New Class';

  @override
  String get editClass => 'Edit Class';

  @override
  String get classNameField => 'Class name (e.g. 7th grade)';

  @override
  String get capacityField => 'Capacity (optional)';

  @override
  String get noClasses => 'No classes yet. Tap + to create one.';

  @override
  String classSubtitleYear(Object year) {
    return 'Year: $year';
  }

  @override
  String classSubtitleYearCapacity(Object year, Object capacity) {
    return 'Year: $year • Capacity: $capacity';
  }

  @override
  String get createYearFirst => 'Create a school year first.';

  @override
  String get newSubject => 'New Subject';

  @override
  String get editSubject => 'Edit Subject';

  @override
  String get subjectNameField => 'Subject name (e.g. Math)';

  @override
  String get coefficientField => 'Coefficient';

  @override
  String get noSubjects => 'No subjects yet. Tap + to create one.';

  @override
  String subjectSubtitle(Object className, Object coefficient) {
    return 'Class: $className • Coefficient: $coefficient';
  }

  @override
  String get createClassFirst => 'Create a class first.';

  @override
  String get newStaffTitle => 'New Staff Member';

  @override
  String get fullNameField => 'Full name';

  @override
  String get positionField => 'Position (e.g. Secretary General, Math Teacher)';

  @override
  String get appAccessLabel => 'App access';

  @override
  String get roleTeacherOption => 'Teacher (grades, attendance, assignments)';

  @override
  String get roleAdminOption => 'Admin (full access)';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get accountCreatedTitle => 'Account created';

  @override
  String get sendLinkToStaffBody =>
      'Send this link to the staff member so they can set their password:';

  @override
  String createAccountFailed(Object error) {
    return 'Could not create the account: $error';
  }

  @override
  String get noStaff => 'No staff members yet. Tap + to add one.';

  @override
  String get inactiveChip => 'Inactive';

  @override
  String get pendingTab => 'Pending';

  @override
  String get approvedTab => 'Approved';

  @override
  String get rejectedTab => 'Rejected';

  @override
  String get newEnrollmentTitle => 'New Enrollment Request';

  @override
  String get studentFirstNameField => 'Student first name';

  @override
  String get studentLastNameField => 'Student last name';

  @override
  String get parentFullNameField => 'Parent full name';

  @override
  String get parentEmailField => 'Parent email';

  @override
  String get parentPhoneField => 'Parent phone (optional)';

  @override
  String get submitButton => 'Submit';

  @override
  String get noRequests => 'Nothing here yet.';

  @override
  String parentSubtitle(Object name, Object email) {
    return 'Parent: $name • $email';
  }

  @override
  String get enrollmentApprovedTitle => 'Enrollment approved';

  @override
  String get parentAccountCreatedBody =>
      'The parent\'s account was created. Send them this link to set their password:';

  @override
  String get rejectTooltip => 'Reject';

  @override
  String get approveTooltip => 'Approve';

  @override
  String get searchStudentHint => 'Search for a student...';

  @override
  String get noActiveSchoolYear => 'No active school year right now.';

  @override
  String get totalToPayLower => 'Total to pay';

  @override
  String get alreadyPaidLower => 'Already paid';

  @override
  String get remainingBalanceLower => 'Remaining balance';

  @override
  String get notConfiguredChip => 'Not set up';

  @override
  String get paidLabel => 'Paid';

  @override
  String get noMatchingStudents => 'No matching students.';

  @override
  String get totalToPayTitle => 'Total to Pay';

  @override
  String get totalAmountField => 'Total (HTG) for the school year';

  @override
  String get recordInstallmentTitle => 'Record a Payment';

  @override
  String get monthField => 'Label (e.g. September 2026)';

  @override
  String get amountPaidField => 'Amount Paid (HTG)';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get paymentDateLabel => 'Payment Date';

  @override
  String get recordButton => 'Record';

  @override
  String get installmentRecordedTitle => 'Payment recorded';

  @override
  String get printReceiptPrompt =>
      'Do you want to print/share the receipt now?';

  @override
  String get laterButton => 'Later';

  @override
  String get printReceiptButton => 'Print Receipt';

  @override
  String get alreadyPaidTitle => 'Already Paid';

  @override
  String get editTotalDueButton => 'Edit Total to Pay';

  @override
  String get noInstallments => 'No payments recorded.';

  @override
  String paidOnLabel(Object date) {
    return 'Paid on: $date';
  }

  @override
  String get installmentFabLabel => 'Payment';

  @override
  String get notGradedYet => 'Not graded yet';

  @override
  String overallAverageLabel(Object term, Object avg) {
    return 'Overall Average ($term): $avg/100';
  }

  @override
  String noGradesForTerm(Object term) {
    return 'No grades yet for $term';
  }

  @override
  String get exportReportCardButton => 'Export Report Card PDF';

  @override
  String get reportCardTab => 'Report Card';

  @override
  String get feesTab => 'Fees';

  @override
  String get noStudentLinked =>
      'This account isn\'t linked to a student record.';

  @override
  String get studentRecordNotFound => 'Student record not found.';

  @override
  String get noChildrenLinked => 'No children are linked to this account.';

  @override
  String get myChildrenTitle => 'My Children';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String classIdSubtitle(Object classId) {
    return 'Class: $classId';
  }

  @override
  String get termLabel => 'Term';

  @override
  String get typeLabel => 'Type';

  @override
  String get maxScoreField => 'Out of (max)';

  @override
  String get chooseClassAndSubject => 'Choose a class and a subject.';

  @override
  String get noStudentsInClass => 'No students in this class.';

  @override
  String get gradeHint => 'Grade';

  @override
  String get saveGradesButton => 'Save Grades';

  @override
  String gradesRecorded(Object count) {
    return '$count grades recorded.';
  }

  @override
  String get noAssignedClasses => 'You don\'t have any assigned classes yet.';

  @override
  String get statusPresent => 'Present';

  @override
  String get statusAbsent => 'Absent';

  @override
  String get statusLate => 'Late';

  @override
  String get statusExcused => 'Excused';

  @override
  String get chooseClass => 'Choose a class.';

  @override
  String get saveAttendanceButton => 'Save Attendance';

  @override
  String attendanceRecorded(Object count) {
    return 'Attendance recorded for $count students.';
  }

  @override
  String get newAssignmentTitle => 'New Assignment';

  @override
  String get titleField => 'Title';

  @override
  String get descriptionField => 'Description';

  @override
  String get dueDateLabel => 'Due Date';

  @override
  String get sendAssignmentButton => 'Send Assignment';

  @override
  String get noAssignmentsYet => 'No assignments yet. Tap + to send one.';

  @override
  String dueDatePrefix(Object date) {
    return 'Due: $date';
  }

  @override
  String get newMessageTitle => 'New Message';

  @override
  String get studentField => 'Student';

  @override
  String get subjectField => 'Subject';

  @override
  String get messageField => 'Message';

  @override
  String get sendButton => 'Send';

  @override
  String get noLinkedStudentAccount =>
      'This student has no linked parent/student account.';

  @override
  String get noSentMessages => 'No messages sent yet. Tap + to send one.';

  @override
  String get noScheduledAssignments => 'No assignments or exams scheduled.';

  @override
  String get noAttendanceRecords => 'No attendance records yet.';

  @override
  String statusCountLabel(Object status, Object count) {
    return '$status: $count';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications.';

  @override
  String get noFeeInfo => 'No fee information yet for this school year.';

  @override
  String loadErrorMessage(Object error) {
    return 'Couldn\'t load the data.\n$error';
  }

  @override
  String get reloginRequired =>
      'Please sign out and back in before changing your password.';

  @override
  String get mustChangePasswordTitle => 'Change Your Password';

  @override
  String get mustChangePasswordBody =>
      'This is your first sign-in. Please choose a new password before continuing.';

  @override
  String get newPasswordField => 'New Password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get confirmPasswordField => 'Confirm Password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get changePasswordButton => 'Change Password';

  @override
  String get sendTempPasswordBody =>
      'Give this information to the employee for their first sign-in. The app will require them to change the password immediately.';

  @override
  String get temporaryPasswordLabel => 'Temporary Password';

  @override
  String get studentEmailOptionalField =>
      'Student email (optional, for the student\'s own account)';

  @override
  String get addSecondParentToggle => 'Add a second parent';

  @override
  String get parent2FullNameField => 'Second parent\'s full name';

  @override
  String get parent2EmailField => 'Second parent\'s email';

  @override
  String get newAccountsCreatedBody =>
      'These accounts were created. Give each person their own information for their first sign-in. The app will require them to change the password immediately.';

  @override
  String get parentRoleLabel => 'Parent';

  @override
  String get accountAlreadyExisted =>
      'This account already existed — no new password.';

  @override
  String get myProfileTitle => 'My Profile';

  @override
  String requestChangeTitle(Object field) {
    return 'Request a change: $field';
  }

  @override
  String get newValueField => 'New value';

  @override
  String get changeRequestSent =>
      'Change request sent to the Admin for approval.';

  @override
  String get sexField => 'Sex';

  @override
  String get myChangeRequestsTitle => 'My Change Requests';

  @override
  String get requestChangeTooltip => 'Request a change';

  @override
  String get changeApplied => 'Change applied.';

  @override
  String get navChangeRequests => 'Change Requests';
}
