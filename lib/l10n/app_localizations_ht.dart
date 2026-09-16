// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Haitian Haitian Creole (`ht`).
class AppLocalizationsHt extends AppLocalizations {
  AppLocalizationsHt([String locale = 'ht']) : super(locale);

  @override
  String get cancel => 'Anile';

  @override
  String get save => 'Sove';

  @override
  String get edit => 'Modifye';

  @override
  String get delete => 'Efase';

  @override
  String get close => 'Fèmen';

  @override
  String get required => 'Obligatwa';

  @override
  String get invalidEmail => 'Email envalid';

  @override
  String get email => 'Email';

  @override
  String get password => 'Modpas';

  @override
  String get classLabel => 'Klas';

  @override
  String errorPrefix(Object error) {
    return 'Erè: $error';
  }

  @override
  String get appName => 'Jesyon Lekòl';

  @override
  String get enterYourEmail => 'Antre email ou';

  @override
  String get enterYourPassword => 'Antre modpas ou';

  @override
  String get loginButton => 'Konekte';

  @override
  String get loginIncorrect => 'Email oswa modpas la pa kòrèk.';

  @override
  String get unauthorizedMessage => 'Ou pa gen aksè a paj sa a.';

  @override
  String get navSchoolYears => 'Ane Lekòl';

  @override
  String get navSubjects => 'Matyè';

  @override
  String get navStaff => 'Anplwaye';

  @override
  String get navEnrollment => 'Enskripsyon';

  @override
  String get navFinance => 'Finans';

  @override
  String get navGrades => 'Nòt';

  @override
  String get navAttendance => 'Prezans';

  @override
  String get navAssignments => 'Devwa';

  @override
  String get navMessages => 'Mesaj';

  @override
  String get newSchoolYear => 'Nouvo Ane Lekòl';

  @override
  String get editSchoolYear => 'Modifye Ane Lekòl';

  @override
  String get yearLabelField => 'Etikèt (eg: 2026-2027)';

  @override
  String get startDateLabel => 'Kòmansman';

  @override
  String get endDateLabel => 'Fen';

  @override
  String get noSchoolYears => 'Poko gen ane lekòl. Peze + pou kreye youn.';

  @override
  String get activate => 'Aktive';

  @override
  String get newClass => 'Nouvo Klas';

  @override
  String get editClass => 'Modifye Klas';

  @override
  String get classNameField => 'Non klas (eg: 7èm AF)';

  @override
  String get capacityField => 'Kapasite (opsyonèl)';

  @override
  String get noClasses => 'Poko gen klas. Peze + pou kreye youn.';

  @override
  String classSubtitleYear(Object year) {
    return 'Ane: $year';
  }

  @override
  String classSubtitleYearCapacity(Object year, Object capacity) {
    return 'Ane: $year • Kapasite: $capacity';
  }

  @override
  String get createYearFirst => 'Kreye yon ane lekòl anvan.';

  @override
  String get newSubject => 'Nouvo Matyè';

  @override
  String get editSubject => 'Modifye Matyè';

  @override
  String get subjectNameField => 'Non matyè (eg: Matematik)';

  @override
  String get coefficientField => 'Kowefisyan';

  @override
  String get noSubjects => 'Poko gen matyè. Peze + pou kreye youn.';

  @override
  String subjectSubtitle(Object className, Object coefficient) {
    return 'Klas: $className • Kowefisyan: $coefficient';
  }

  @override
  String get createClassFirst => 'Kreye yon klas anvan.';

  @override
  String get newStaffTitle => 'Nouvo Anplwaye';

  @override
  String get fullNameField => 'Non konplè';

  @override
  String get positionField =>
      'Pozisyon (eg: Sekretè Jeneral, Pwofesè Matematik)';

  @override
  String get appAccessLabel => 'Aksè nan aplikasyon an';

  @override
  String get roleTeacherOption => 'Pwofesè (nòt, prezans, devwa)';

  @override
  String get roleAdminOption => 'Admin (aksè konplè)';

  @override
  String get createAccountButton => 'Kreye Kont';

  @override
  String get accountCreatedTitle => 'Kont kreye';

  @override
  String get sendLinkToStaffBody =>
      'Voye lyen sa a bay anplwaye a pou li defini modpas li:';

  @override
  String createAccountFailed(Object error) {
    return 'Pa kapab kreye kont lan: $error';
  }

  @override
  String get noStaff => 'Poko gen anplwaye. Peze + pou ajoute youn.';

  @override
  String get inactiveChip => 'Inaktif';

  @override
  String get pendingTab => 'Annatant';

  @override
  String get approvedTab => 'Apwouve';

  @override
  String get rejectedTab => 'Rejte';

  @override
  String get newEnrollmentTitle => 'Nouvo Demann Enskripsyon';

  @override
  String get studentFirstNameField => 'Prenon elèv';

  @override
  String get studentLastNameField => 'Non fanmi elèv';

  @override
  String get parentFullNameField => 'Non konplè paran';

  @override
  String get parentEmailField => 'Email paran';

  @override
  String get parentPhoneField => 'Telefòn paran (opsyonèl)';

  @override
  String get submitButton => 'Soumèt';

  @override
  String get noRequests => 'Pa gen anyen isit la.';

  @override
  String parentSubtitle(Object name, Object email) {
    return 'Paran: $name • $email';
  }

  @override
  String get enrollmentApprovedTitle => 'Enskripsyon apwouve';

  @override
  String get parentAccountCreatedBody =>
      'Kont paran an kreye. Voye lyen sa a ba li pou li defini modpas li:';

  @override
  String get rejectTooltip => 'Rejte';

  @override
  String get approveTooltip => 'Apwouve';

  @override
  String get searchStudentHint => 'Chèche yon elèv...';

  @override
  String get noActiveSchoolYear => 'Pa gen ane lekòl aktif kounye a.';

  @override
  String get totalToPayLower => 'Total pou peye';

  @override
  String get alreadyPaidLower => 'Deja peye';

  @override
  String get remainingBalanceLower => 'Rès pou peye';

  @override
  String get notConfiguredChip => 'Poko konfigire';

  @override
  String get paidLabel => 'Peye';

  @override
  String get noMatchingStudents => 'Pa gen elèv ki koresponn.';

  @override
  String get totalToPayTitle => 'Total pou Peye';

  @override
  String get totalAmountField => 'Total (HTG) pou ane lekòl la';

  @override
  String get recordInstallmentTitle => 'Anrejistre yon Vèsman';

  @override
  String get monthField => 'Etikèt (eg: Septanm 2026)';

  @override
  String get amountPaidField => 'Montan Peye (HTG)';

  @override
  String get invalidAmount => 'Montan envalid';

  @override
  String get paymentDateLabel => 'Dat Peman';

  @override
  String get recordButton => 'Anrejistre';

  @override
  String get installmentRecordedTitle => 'Vèsman anrejistre';

  @override
  String get printReceiptPrompt => 'Ou vle enprime/pataje resi a kounye a?';

  @override
  String get laterButton => 'Pita';

  @override
  String get printReceiptButton => 'Enprime Resi';

  @override
  String get alreadyPaidTitle => 'Deja Peye';

  @override
  String get editTotalDueButton => 'Modifye Total pou Peye';

  @override
  String get noInstallments => 'Pa gen vèsman anrejistre.';

  @override
  String paidOnLabel(Object date) {
    return 'Peye: $date';
  }

  @override
  String get installmentFabLabel => 'Vèsman';

  @override
  String get notGradedYet => 'Poko gen nòt';

  @override
  String overallAverageLabel(Object term, Object avg) {
    return 'Mwayèn Jeneral ($term): $avg/100';
  }

  @override
  String noGradesForTerm(Object term) {
    return 'Poko gen nòt pou $term';
  }

  @override
  String get exportReportCardButton => 'Ekspòte Bilten PDF';

  @override
  String get reportCardTab => 'Bilten';

  @override
  String get feesTab => 'Frè';

  @override
  String get noStudentLinked => 'Kont sa a pa lye ak yon dosye elèv.';

  @override
  String get studentRecordNotFound => 'Dosye elèv la pa jwenn.';

  @override
  String get noChildrenLinked => 'Pa gen okenn pitit ki lye ak kont sa a.';

  @override
  String get myChildrenTitle => 'Pitit Mwen Yo';

  @override
  String get notificationsTooltip => 'Notifikasyon';

  @override
  String classIdSubtitle(Object classId) {
    return 'Klas: $classId';
  }

  @override
  String get termLabel => 'Peryòd';

  @override
  String get typeLabel => 'Tip';

  @override
  String get maxScoreField => 'Sou (max)';

  @override
  String get chooseClassAndSubject => 'Chwazi yon klas ak yon matyè.';

  @override
  String get noStudentsInClass => 'Pa gen elèv nan klas sa a.';

  @override
  String get gradeHint => 'Nòt';

  @override
  String get saveGradesButton => 'Anrejistre Nòt yo';

  @override
  String gradesRecorded(Object count) {
    return '$count nòt anrejistre.';
  }

  @override
  String get noAssignedClasses => 'Ou poko gen klas ki asiyen a ou.';

  @override
  String get statusPresent => 'Prezan';

  @override
  String get statusAbsent => 'Absan';

  @override
  String get statusLate => 'An reta';

  @override
  String get statusExcused => 'Eskize';

  @override
  String get chooseClass => 'Chwazi yon klas.';

  @override
  String get saveAttendanceButton => 'Anrejistre Prezans';

  @override
  String attendanceRecorded(Object count) {
    return 'Prezans anrejistre pou $count elèv.';
  }

  @override
  String get newAssignmentTitle => 'Nouvo Devwa';

  @override
  String get titleField => 'Tit';

  @override
  String get descriptionField => 'Deskripsyon';

  @override
  String get dueDateLabel => 'Delè';

  @override
  String get sendAssignmentButton => 'Voye Devwa';

  @override
  String get noAssignmentsYet => 'Poko gen devwa. Peze + pou voye youn.';

  @override
  String dueDatePrefix(Object date) {
    return 'Delè: $date';
  }

  @override
  String get newMessageTitle => 'Nouvo Mesaj';

  @override
  String get studentField => 'Elèv';

  @override
  String get subjectField => 'Sijè';

  @override
  String get messageField => 'Mesaj';

  @override
  String get sendButton => 'Voye';

  @override
  String get noLinkedStudentAccount =>
      'Elèv sa a pa gen kont paran/elèv ki lye.';

  @override
  String get noSentMessages => 'Poko gen mesaj voye. Peze + pou voye youn.';

  @override
  String get noScheduledAssignments => 'Pa gen devwa oswa egzamen pwograme.';

  @override
  String get noAttendanceRecords => 'Poko gen dosye prezans.';

  @override
  String statusCountLabel(Object status, Object count) {
    return '$status: $count';
  }

  @override
  String get notificationsTitle => 'Notifikasyon';

  @override
  String get noNotifications => 'Pa gen notifikasyon.';

  @override
  String get noFeeInfo => 'Poko gen enfòmasyon frè pou ane lekòl sa a.';

  @override
  String loadErrorMessage(Object error) {
    return 'Pa kapab chaje done yo.\n$error';
  }
}
