import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ht.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('ht'),
  ];

  /// No description provided for @cancel.
  ///
  /// In ht, this message translates to:
  /// **'Anile'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ht, this message translates to:
  /// **'Sove'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In ht, this message translates to:
  /// **'Modifye'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ht, this message translates to:
  /// **'Efase'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In ht, this message translates to:
  /// **'Fèmen'**
  String get close;

  /// No description provided for @required.
  ///
  /// In ht, this message translates to:
  /// **'Obligatwa'**
  String get required;

  /// No description provided for @invalidEmail.
  ///
  /// In ht, this message translates to:
  /// **'Email envalid'**
  String get invalidEmail;

  /// No description provided for @email.
  ///
  /// In ht, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ht, this message translates to:
  /// **'Modpas'**
  String get password;

  /// No description provided for @classLabel.
  ///
  /// In ht, this message translates to:
  /// **'Klas'**
  String get classLabel;

  /// No description provided for @errorPrefix.
  ///
  /// In ht, this message translates to:
  /// **'Erè: {error}'**
  String errorPrefix(Object error);

  /// No description provided for @appName.
  ///
  /// In ht, this message translates to:
  /// **'Jesyon Lekòl'**
  String get appName;

  /// No description provided for @enterYourEmail.
  ///
  /// In ht, this message translates to:
  /// **'Antre email ou'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In ht, this message translates to:
  /// **'Antre modpas ou'**
  String get enterYourPassword;

  /// No description provided for @loginButton.
  ///
  /// In ht, this message translates to:
  /// **'Konekte'**
  String get loginButton;

  /// No description provided for @loginIncorrect.
  ///
  /// In ht, this message translates to:
  /// **'Email oswa modpas la pa kòrèk.'**
  String get loginIncorrect;

  /// No description provided for @unauthorizedMessage.
  ///
  /// In ht, this message translates to:
  /// **'Ou pa gen aksè a paj sa a.'**
  String get unauthorizedMessage;

  /// No description provided for @navSchoolYears.
  ///
  /// In ht, this message translates to:
  /// **'Ane Lekòl'**
  String get navSchoolYears;

  /// No description provided for @navSubjects.
  ///
  /// In ht, this message translates to:
  /// **'Matyè'**
  String get navSubjects;

  /// No description provided for @navStaff.
  ///
  /// In ht, this message translates to:
  /// **'Anplwaye'**
  String get navStaff;

  /// No description provided for @navEnrollment.
  ///
  /// In ht, this message translates to:
  /// **'Enskripsyon'**
  String get navEnrollment;

  /// No description provided for @navFinance.
  ///
  /// In ht, this message translates to:
  /// **'Finans'**
  String get navFinance;

  /// No description provided for @navGrades.
  ///
  /// In ht, this message translates to:
  /// **'Nòt'**
  String get navGrades;

  /// No description provided for @navAttendance.
  ///
  /// In ht, this message translates to:
  /// **'Prezans'**
  String get navAttendance;

  /// No description provided for @navAssignments.
  ///
  /// In ht, this message translates to:
  /// **'Devwa'**
  String get navAssignments;

  /// No description provided for @navMessages.
  ///
  /// In ht, this message translates to:
  /// **'Mesaj'**
  String get navMessages;

  /// No description provided for @newSchoolYear.
  ///
  /// In ht, this message translates to:
  /// **'Nouvo Ane Lekòl'**
  String get newSchoolYear;

  /// No description provided for @editSchoolYear.
  ///
  /// In ht, this message translates to:
  /// **'Modifye Ane Lekòl'**
  String get editSchoolYear;

  /// No description provided for @yearLabelField.
  ///
  /// In ht, this message translates to:
  /// **'Etikèt (eg: 2026-2027)'**
  String get yearLabelField;

  /// No description provided for @startDateLabel.
  ///
  /// In ht, this message translates to:
  /// **'Kòmansman'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In ht, this message translates to:
  /// **'Fen'**
  String get endDateLabel;

  /// No description provided for @noSchoolYears.
  ///
  /// In ht, this message translates to:
  /// **'Poko gen ane lekòl. Peze + pou kreye youn.'**
  String get noSchoolYears;

  /// No description provided for @activate.
  ///
  /// In ht, this message translates to:
  /// **'Aktive'**
  String get activate;

  /// No description provided for @newClass.
  ///
  /// In ht, this message translates to:
  /// **'Nouvo Klas'**
  String get newClass;

  /// No description provided for @editClass.
  ///
  /// In ht, this message translates to:
  /// **'Modifye Klas'**
  String get editClass;

  /// No description provided for @classNameField.
  ///
  /// In ht, this message translates to:
  /// **'Non klas (eg: 7èm AF)'**
  String get classNameField;

  /// No description provided for @capacityField.
  ///
  /// In ht, this message translates to:
  /// **'Kapasite (opsyonèl)'**
  String get capacityField;

  /// No description provided for @noClasses.
  ///
  /// In ht, this message translates to:
  /// **'Poko gen klas. Peze + pou kreye youn.'**
  String get noClasses;

  /// No description provided for @classSubtitleYear.
  ///
  /// In ht, this message translates to:
  /// **'Ane: {year}'**
  String classSubtitleYear(Object year);

  /// No description provided for @classSubtitleYearCapacity.
  ///
  /// In ht, this message translates to:
  /// **'Ane: {year} • Kapasite: {capacity}'**
  String classSubtitleYearCapacity(Object year, Object capacity);

  /// No description provided for @createYearFirst.
  ///
  /// In ht, this message translates to:
  /// **'Kreye yon ane lekòl anvan.'**
  String get createYearFirst;

  /// No description provided for @newSubject.
  ///
  /// In ht, this message translates to:
  /// **'Nouvo Matyè'**
  String get newSubject;

  /// No description provided for @editSubject.
  ///
  /// In ht, this message translates to:
  /// **'Modifye Matyè'**
  String get editSubject;

  /// No description provided for @subjectNameField.
  ///
  /// In ht, this message translates to:
  /// **'Non matyè (eg: Matematik)'**
  String get subjectNameField;

  /// No description provided for @coefficientField.
  ///
  /// In ht, this message translates to:
  /// **'Kowefisyan'**
  String get coefficientField;

  /// No description provided for @noSubjects.
  ///
  /// In ht, this message translates to:
  /// **'Poko gen matyè. Peze + pou kreye youn.'**
  String get noSubjects;

  /// No description provided for @subjectSubtitle.
  ///
  /// In ht, this message translates to:
  /// **'Klas: {className} • Kowefisyan: {coefficient}'**
  String subjectSubtitle(Object className, Object coefficient);

  /// No description provided for @createClassFirst.
  ///
  /// In ht, this message translates to:
  /// **'Kreye yon klas anvan.'**
  String get createClassFirst;

  /// No description provided for @newStaffTitle.
  ///
  /// In ht, this message translates to:
  /// **'Nouvo Anplwaye'**
  String get newStaffTitle;

  /// No description provided for @fullNameField.
  ///
  /// In ht, this message translates to:
  /// **'Non konplè'**
  String get fullNameField;

  /// No description provided for @positionField.
  ///
  /// In ht, this message translates to:
  /// **'Pozisyon (eg: Sekretè Jeneral, Pwofesè Matematik)'**
  String get positionField;

  /// No description provided for @appAccessLabel.
  ///
  /// In ht, this message translates to:
  /// **'Aksè nan aplikasyon an'**
  String get appAccessLabel;

  /// No description provided for @roleTeacherOption.
  ///
  /// In ht, this message translates to:
  /// **'Pwofesè (nòt, prezans, devwa)'**
  String get roleTeacherOption;

  /// No description provided for @roleAdminOption.
  ///
  /// In ht, this message translates to:
  /// **'Admin (aksè konplè)'**
  String get roleAdminOption;

  /// No description provided for @createAccountButton.
  ///
  /// In ht, this message translates to:
  /// **'Kreye Kont'**
  String get createAccountButton;

  /// No description provided for @accountCreatedTitle.
  ///
  /// In ht, this message translates to:
  /// **'Kont kreye'**
  String get accountCreatedTitle;

  /// No description provided for @sendLinkToStaffBody.
  ///
  /// In ht, this message translates to:
  /// **'Voye lyen sa a bay anplwaye a pou li defini modpas li:'**
  String get sendLinkToStaffBody;

  /// No description provided for @createAccountFailed.
  ///
  /// In ht, this message translates to:
  /// **'Pa kapab kreye kont lan: {error}'**
  String createAccountFailed(Object error);

  /// No description provided for @noStaff.
  ///
  /// In ht, this message translates to:
  /// **'Poko gen anplwaye. Peze + pou ajoute youn.'**
  String get noStaff;

  /// No description provided for @inactiveChip.
  ///
  /// In ht, this message translates to:
  /// **'Inaktif'**
  String get inactiveChip;

  /// No description provided for @pendingTab.
  ///
  /// In ht, this message translates to:
  /// **'Annatant'**
  String get pendingTab;

  /// No description provided for @approvedTab.
  ///
  /// In ht, this message translates to:
  /// **'Apwouve'**
  String get approvedTab;

  /// No description provided for @rejectedTab.
  ///
  /// In ht, this message translates to:
  /// **'Rejte'**
  String get rejectedTab;

  /// No description provided for @newEnrollmentTitle.
  ///
  /// In ht, this message translates to:
  /// **'Nouvo Demann Enskripsyon'**
  String get newEnrollmentTitle;

  /// No description provided for @studentFirstNameField.
  ///
  /// In ht, this message translates to:
  /// **'Prenon elèv'**
  String get studentFirstNameField;

  /// No description provided for @studentLastNameField.
  ///
  /// In ht, this message translates to:
  /// **'Non fanmi elèv'**
  String get studentLastNameField;

  /// No description provided for @parentFullNameField.
  ///
  /// In ht, this message translates to:
  /// **'Non konplè paran'**
  String get parentFullNameField;

  /// No description provided for @parentEmailField.
  ///
  /// In ht, this message translates to:
  /// **'Email paran'**
  String get parentEmailField;

  /// No description provided for @parentPhoneField.
  ///
  /// In ht, this message translates to:
  /// **'Telefòn paran (opsyonèl)'**
  String get parentPhoneField;

  /// No description provided for @submitButton.
  ///
  /// In ht, this message translates to:
  /// **'Soumèt'**
  String get submitButton;

  /// No description provided for @noRequests.
  ///
  /// In ht, this message translates to:
  /// **'Pa gen anyen isit la.'**
  String get noRequests;

  /// No description provided for @parentSubtitle.
  ///
  /// In ht, this message translates to:
  /// **'Paran: {name} • {email}'**
  String parentSubtitle(Object name, Object email);

  /// No description provided for @enrollmentApprovedTitle.
  ///
  /// In ht, this message translates to:
  /// **'Enskripsyon apwouve'**
  String get enrollmentApprovedTitle;

  /// No description provided for @parentAccountCreatedBody.
  ///
  /// In ht, this message translates to:
  /// **'Kont paran an kreye. Voye lyen sa a ba li pou li defini modpas li:'**
  String get parentAccountCreatedBody;

  /// No description provided for @rejectTooltip.
  ///
  /// In ht, this message translates to:
  /// **'Rejte'**
  String get rejectTooltip;

  /// No description provided for @approveTooltip.
  ///
  /// In ht, this message translates to:
  /// **'Apwouve'**
  String get approveTooltip;

  /// No description provided for @searchStudentHint.
  ///
  /// In ht, this message translates to:
  /// **'Chèche yon elèv...'**
  String get searchStudentHint;

  /// No description provided for @noActiveSchoolYear.
  ///
  /// In ht, this message translates to:
  /// **'Pa gen ane lekòl aktif kounye a.'**
  String get noActiveSchoolYear;

  /// No description provided for @totalToPayLower.
  ///
  /// In ht, this message translates to:
  /// **'Total pou peye'**
  String get totalToPayLower;

  /// No description provided for @alreadyPaidLower.
  ///
  /// In ht, this message translates to:
  /// **'Deja peye'**
  String get alreadyPaidLower;

  /// No description provided for @remainingBalanceLower.
  ///
  /// In ht, this message translates to:
  /// **'Rès pou peye'**
  String get remainingBalanceLower;

  /// No description provided for @notConfiguredChip.
  ///
  /// In ht, this message translates to:
  /// **'Poko konfigire'**
  String get notConfiguredChip;

  /// No description provided for @paidLabel.
  ///
  /// In ht, this message translates to:
  /// **'Peye'**
  String get paidLabel;

  /// No description provided for @noMatchingStudents.
  ///
  /// In ht, this message translates to:
  /// **'Pa gen elèv ki koresponn.'**
  String get noMatchingStudents;

  /// No description provided for @totalToPayTitle.
  ///
  /// In ht, this message translates to:
  /// **'Total pou Peye'**
  String get totalToPayTitle;

  /// No description provided for @totalAmountField.
  ///
  /// In ht, this message translates to:
  /// **'Total (HTG) pou ane lekòl la'**
  String get totalAmountField;

  /// No description provided for @recordInstallmentTitle.
  ///
  /// In ht, this message translates to:
  /// **'Anrejistre yon Vèsman'**
  String get recordInstallmentTitle;

  /// No description provided for @monthField.
  ///
  /// In ht, this message translates to:
  /// **'Etikèt (eg: Septanm 2026)'**
  String get monthField;

  /// No description provided for @amountPaidField.
  ///
  /// In ht, this message translates to:
  /// **'Montan Peye (HTG)'**
  String get amountPaidField;

  /// No description provided for @invalidAmount.
  ///
  /// In ht, this message translates to:
  /// **'Montan envalid'**
  String get invalidAmount;

  /// No description provided for @paymentDateLabel.
  ///
  /// In ht, this message translates to:
  /// **'Dat Peman'**
  String get paymentDateLabel;

  /// No description provided for @recordButton.
  ///
  /// In ht, this message translates to:
  /// **'Anrejistre'**
  String get recordButton;

  /// No description provided for @installmentRecordedTitle.
  ///
  /// In ht, this message translates to:
  /// **'Vèsman anrejistre'**
  String get installmentRecordedTitle;

  /// No description provided for @printReceiptPrompt.
  ///
  /// In ht, this message translates to:
  /// **'Ou vle enprime/pataje resi a kounye a?'**
  String get printReceiptPrompt;

  /// No description provided for @laterButton.
  ///
  /// In ht, this message translates to:
  /// **'Pita'**
  String get laterButton;

  /// No description provided for @printReceiptButton.
  ///
  /// In ht, this message translates to:
  /// **'Enprime Resi'**
  String get printReceiptButton;

  /// No description provided for @alreadyPaidTitle.
  ///
  /// In ht, this message translates to:
  /// **'Deja Peye'**
  String get alreadyPaidTitle;

  /// No description provided for @editTotalDueButton.
  ///
  /// In ht, this message translates to:
  /// **'Modifye Total pou Peye'**
  String get editTotalDueButton;

  /// No description provided for @noInstallments.
  ///
  /// In ht, this message translates to:
  /// **'Pa gen vèsman anrejistre.'**
  String get noInstallments;

  /// No description provided for @paidOnLabel.
  ///
  /// In ht, this message translates to:
  /// **'Peye: {date}'**
  String paidOnLabel(Object date);

  /// No description provided for @installmentFabLabel.
  ///
  /// In ht, this message translates to:
  /// **'Vèsman'**
  String get installmentFabLabel;

  /// No description provided for @notGradedYet.
  ///
  /// In ht, this message translates to:
  /// **'Poko gen nòt'**
  String get notGradedYet;

  /// No description provided for @overallAverageLabel.
  ///
  /// In ht, this message translates to:
  /// **'Mwayèn Jeneral ({term}): {avg}/100'**
  String overallAverageLabel(Object term, Object avg);

  /// No description provided for @noGradesForTerm.
  ///
  /// In ht, this message translates to:
  /// **'Poko gen nòt pou {term}'**
  String noGradesForTerm(Object term);

  /// No description provided for @exportReportCardButton.
  ///
  /// In ht, this message translates to:
  /// **'Ekspòte Bilten PDF'**
  String get exportReportCardButton;

  /// No description provided for @reportCardTab.
  ///
  /// In ht, this message translates to:
  /// **'Bilten'**
  String get reportCardTab;

  /// No description provided for @feesTab.
  ///
  /// In ht, this message translates to:
  /// **'Frè'**
  String get feesTab;

  /// No description provided for @noStudentLinked.
  ///
  /// In ht, this message translates to:
  /// **'Kont sa a pa lye ak yon dosye elèv.'**
  String get noStudentLinked;

  /// No description provided for @studentRecordNotFound.
  ///
  /// In ht, this message translates to:
  /// **'Dosye elèv la pa jwenn.'**
  String get studentRecordNotFound;

  /// No description provided for @noChildrenLinked.
  ///
  /// In ht, this message translates to:
  /// **'Pa gen okenn pitit ki lye ak kont sa a.'**
  String get noChildrenLinked;

  /// No description provided for @myChildrenTitle.
  ///
  /// In ht, this message translates to:
  /// **'Pitit Mwen Yo'**
  String get myChildrenTitle;

  /// No description provided for @notificationsTooltip.
  ///
  /// In ht, this message translates to:
  /// **'Notifikasyon'**
  String get notificationsTooltip;

  /// No description provided for @classIdSubtitle.
  ///
  /// In ht, this message translates to:
  /// **'Klas: {classId}'**
  String classIdSubtitle(Object classId);

  /// No description provided for @termLabel.
  ///
  /// In ht, this message translates to:
  /// **'Peryòd'**
  String get termLabel;

  /// No description provided for @typeLabel.
  ///
  /// In ht, this message translates to:
  /// **'Tip'**
  String get typeLabel;

  /// No description provided for @maxScoreField.
  ///
  /// In ht, this message translates to:
  /// **'Sou (max)'**
  String get maxScoreField;

  /// No description provided for @chooseClassAndSubject.
  ///
  /// In ht, this message translates to:
  /// **'Chwazi yon klas ak yon matyè.'**
  String get chooseClassAndSubject;

  /// No description provided for @noStudentsInClass.
  ///
  /// In ht, this message translates to:
  /// **'Pa gen elèv nan klas sa a.'**
  String get noStudentsInClass;

  /// No description provided for @gradeHint.
  ///
  /// In ht, this message translates to:
  /// **'Nòt'**
  String get gradeHint;

  /// No description provided for @saveGradesButton.
  ///
  /// In ht, this message translates to:
  /// **'Anrejistre Nòt yo'**
  String get saveGradesButton;

  /// No description provided for @gradesRecorded.
  ///
  /// In ht, this message translates to:
  /// **'{count} nòt anrejistre.'**
  String gradesRecorded(Object count);

  /// No description provided for @noAssignedClasses.
  ///
  /// In ht, this message translates to:
  /// **'Ou poko gen klas ki asiyen a ou.'**
  String get noAssignedClasses;

  /// No description provided for @statusPresent.
  ///
  /// In ht, this message translates to:
  /// **'Prezan'**
  String get statusPresent;

  /// No description provided for @statusAbsent.
  ///
  /// In ht, this message translates to:
  /// **'Absan'**
  String get statusAbsent;

  /// No description provided for @statusLate.
  ///
  /// In ht, this message translates to:
  /// **'An reta'**
  String get statusLate;

  /// No description provided for @statusExcused.
  ///
  /// In ht, this message translates to:
  /// **'Eskize'**
  String get statusExcused;

  /// No description provided for @chooseClass.
  ///
  /// In ht, this message translates to:
  /// **'Chwazi yon klas.'**
  String get chooseClass;

  /// No description provided for @saveAttendanceButton.
  ///
  /// In ht, this message translates to:
  /// **'Anrejistre Prezans'**
  String get saveAttendanceButton;

  /// No description provided for @attendanceRecorded.
  ///
  /// In ht, this message translates to:
  /// **'Prezans anrejistre pou {count} elèv.'**
  String attendanceRecorded(Object count);

  /// No description provided for @newAssignmentTitle.
  ///
  /// In ht, this message translates to:
  /// **'Nouvo Devwa'**
  String get newAssignmentTitle;

  /// No description provided for @titleField.
  ///
  /// In ht, this message translates to:
  /// **'Tit'**
  String get titleField;

  /// No description provided for @descriptionField.
  ///
  /// In ht, this message translates to:
  /// **'Deskripsyon'**
  String get descriptionField;

  /// No description provided for @dueDateLabel.
  ///
  /// In ht, this message translates to:
  /// **'Delè'**
  String get dueDateLabel;

  /// No description provided for @sendAssignmentButton.
  ///
  /// In ht, this message translates to:
  /// **'Voye Devwa'**
  String get sendAssignmentButton;

  /// No description provided for @noAssignmentsYet.
  ///
  /// In ht, this message translates to:
  /// **'Poko gen devwa. Peze + pou voye youn.'**
  String get noAssignmentsYet;

  /// No description provided for @dueDatePrefix.
  ///
  /// In ht, this message translates to:
  /// **'Delè: {date}'**
  String dueDatePrefix(Object date);

  /// No description provided for @newMessageTitle.
  ///
  /// In ht, this message translates to:
  /// **'Nouvo Mesaj'**
  String get newMessageTitle;

  /// No description provided for @studentField.
  ///
  /// In ht, this message translates to:
  /// **'Elèv'**
  String get studentField;

  /// No description provided for @subjectField.
  ///
  /// In ht, this message translates to:
  /// **'Sijè'**
  String get subjectField;

  /// No description provided for @messageField.
  ///
  /// In ht, this message translates to:
  /// **'Mesaj'**
  String get messageField;

  /// No description provided for @sendButton.
  ///
  /// In ht, this message translates to:
  /// **'Voye'**
  String get sendButton;

  /// No description provided for @noLinkedStudentAccount.
  ///
  /// In ht, this message translates to:
  /// **'Elèv sa a pa gen kont paran/elèv ki lye.'**
  String get noLinkedStudentAccount;

  /// No description provided for @noSentMessages.
  ///
  /// In ht, this message translates to:
  /// **'Poko gen mesaj voye. Peze + pou voye youn.'**
  String get noSentMessages;

  /// No description provided for @noScheduledAssignments.
  ///
  /// In ht, this message translates to:
  /// **'Pa gen devwa oswa egzamen pwograme.'**
  String get noScheduledAssignments;

  /// No description provided for @noAttendanceRecords.
  ///
  /// In ht, this message translates to:
  /// **'Poko gen dosye prezans.'**
  String get noAttendanceRecords;

  /// No description provided for @statusCountLabel.
  ///
  /// In ht, this message translates to:
  /// **'{status}: {count}'**
  String statusCountLabel(Object status, Object count);

  /// No description provided for @notificationsTitle.
  ///
  /// In ht, this message translates to:
  /// **'Notifikasyon'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In ht, this message translates to:
  /// **'Pa gen notifikasyon.'**
  String get noNotifications;

  /// No description provided for @noFeeInfo.
  ///
  /// In ht, this message translates to:
  /// **'Poko gen enfòmasyon frè pou ane lekòl sa a.'**
  String get noFeeInfo;

  /// No description provided for @loadErrorMessage.
  ///
  /// In ht, this message translates to:
  /// **'Pa kapab chaje done yo.\n{error}'**
  String loadErrorMessage(Object error);

  /// No description provided for @reloginRequired.
  ///
  /// In ht, this message translates to:
  /// **'Tanpri dekonekte epi rekonekte anvan w chanje modpas la.'**
  String get reloginRequired;

  /// No description provided for @mustChangePasswordTitle.
  ///
  /// In ht, this message translates to:
  /// **'Chanje Modpas Ou'**
  String get mustChangePasswordTitle;

  /// No description provided for @mustChangePasswordBody.
  ///
  /// In ht, this message translates to:
  /// **'Sa se premye fwa ou konekte. Tanpri chwazi yon nouvo modpas anvan w kontinye.'**
  String get mustChangePasswordBody;

  /// No description provided for @newPasswordField.
  ///
  /// In ht, this message translates to:
  /// **'Nouvo Modpas'**
  String get newPasswordField;

  /// No description provided for @passwordTooShort.
  ///
  /// In ht, this message translates to:
  /// **'Modpas la dwe gen omwen 6 karaktè'**
  String get passwordTooShort;

  /// No description provided for @confirmPasswordField.
  ///
  /// In ht, this message translates to:
  /// **'Konfime Modpas'**
  String get confirmPasswordField;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In ht, this message translates to:
  /// **'Modpas yo pa menm'**
  String get passwordsDontMatch;

  /// No description provided for @changePasswordButton.
  ///
  /// In ht, this message translates to:
  /// **'Chanje Modpas'**
  String get changePasswordButton;

  /// No description provided for @sendTempPasswordBody.
  ///
  /// In ht, this message translates to:
  /// **'Bay anplwaye a enfòmasyon sa yo pou premye login li. Aplikasyon an ap mande l chanje modpas la imedyatman.'**
  String get sendTempPasswordBody;

  /// No description provided for @temporaryPasswordLabel.
  ///
  /// In ht, this message translates to:
  /// **'Modpas Tanporè'**
  String get temporaryPasswordLabel;

  /// No description provided for @studentEmailOptionalField.
  ///
  /// In ht, this message translates to:
  /// **'Email elèv (opsyonèl, pou kont pwòp elèv la)'**
  String get studentEmailOptionalField;

  /// No description provided for @addSecondParentToggle.
  ///
  /// In ht, this message translates to:
  /// **'Ajoute yon dezyèm paran'**
  String get addSecondParentToggle;

  /// No description provided for @parent2FullNameField.
  ///
  /// In ht, this message translates to:
  /// **'Non konplè dezyèm paran'**
  String get parent2FullNameField;

  /// No description provided for @parent2EmailField.
  ///
  /// In ht, this message translates to:
  /// **'Email dezyèm paran'**
  String get parent2EmailField;

  /// No description provided for @newAccountsCreatedBody.
  ///
  /// In ht, this message translates to:
  /// **'Kont sa yo kreye. Bay chak moun enfòmasyon pa yo pou premye login. Aplikasyon an ap mande yo chanje modpas la imedyatman.'**
  String get newAccountsCreatedBody;

  /// No description provided for @parentRoleLabel.
  ///
  /// In ht, this message translates to:
  /// **'Paran'**
  String get parentRoleLabel;

  /// No description provided for @accountAlreadyExisted.
  ///
  /// In ht, this message translates to:
  /// **'Kont sa a te deja egziste — pa gen nouvo modpas.'**
  String get accountAlreadyExisted;

  /// No description provided for @myProfileTitle.
  ///
  /// In ht, this message translates to:
  /// **'Pwofil Mwen'**
  String get myProfileTitle;

  /// No description provided for @requestChangeTitle.
  ///
  /// In ht, this message translates to:
  /// **'Mande chanjman: {field}'**
  String requestChangeTitle(Object field);

  /// No description provided for @newValueField.
  ///
  /// In ht, this message translates to:
  /// **'Nouvo valè'**
  String get newValueField;

  /// No description provided for @changeRequestSent.
  ///
  /// In ht, this message translates to:
  /// **'Demann chanjman voye bay Admin pou apwobasyon.'**
  String get changeRequestSent;

  /// No description provided for @sexField.
  ///
  /// In ht, this message translates to:
  /// **'Sèks'**
  String get sexField;

  /// No description provided for @myChangeRequestsTitle.
  ///
  /// In ht, this message translates to:
  /// **'Demann Chanjman Mwen Yo'**
  String get myChangeRequestsTitle;

  /// No description provided for @requestChangeTooltip.
  ///
  /// In ht, this message translates to:
  /// **'Mande chanjman'**
  String get requestChangeTooltip;

  /// No description provided for @changeApplied.
  ///
  /// In ht, this message translates to:
  /// **'Chanjman aplike.'**
  String get changeApplied;

  /// No description provided for @navChangeRequests.
  ///
  /// In ht, this message translates to:
  /// **'Demann Chanjman'**
  String get navChangeRequests;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'ht'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ht':
      return AppLocalizationsHt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
