// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get close => 'Fermer';

  @override
  String get required => 'Obligatoire';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get classLabel => 'Classe';

  @override
  String errorPrefix(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get appName => 'Jesyon Lekòl';

  @override
  String get enterYourEmail => 'Entrez votre email';

  @override
  String get enterYourPassword => 'Entrez votre mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginIncorrect => 'Email ou mot de passe incorrect.';

  @override
  String get unauthorizedMessage => 'Vous n\'avez pas accès à cette page.';

  @override
  String get navSchoolYears => 'Année Scolaire';

  @override
  String get navSubjects => 'Matières';

  @override
  String get navStaff => 'Employés';

  @override
  String get navEnrollment => 'Inscriptions';

  @override
  String get navFinance => 'Finances';

  @override
  String get navGrades => 'Notes';

  @override
  String get navAttendance => 'Présences';

  @override
  String get navAssignments => 'Devoirs';

  @override
  String get navMessages => 'Messages';

  @override
  String get newSchoolYear => 'Nouvelle Année Scolaire';

  @override
  String get editSchoolYear => 'Modifier l\'Année Scolaire';

  @override
  String get yearLabelField => 'Libellé (ex : 2026-2027)';

  @override
  String get startDateLabel => 'Début';

  @override
  String get endDateLabel => 'Fin';

  @override
  String get noSchoolYears =>
      'Aucune année scolaire pour l\'instant. Appuyez sur + pour en créer une.';

  @override
  String get activate => 'Activer';

  @override
  String get newClass => 'Nouvelle Classe';

  @override
  String get editClass => 'Modifier la Classe';

  @override
  String get classNameField => 'Nom de la classe (ex : 7ème AF)';

  @override
  String get capacityField => 'Capacité (optionnel)';

  @override
  String get noClasses =>
      'Aucune classe pour l\'instant. Appuyez sur + pour en créer une.';

  @override
  String classSubtitleYear(Object year) {
    return 'Année : $year';
  }

  @override
  String classSubtitleYearCapacity(Object year, Object capacity) {
    return 'Année : $year • Capacité : $capacity';
  }

  @override
  String get createYearFirst => 'Créez d\'abord une année scolaire.';

  @override
  String get newSubject => 'Nouvelle Matière';

  @override
  String get editSubject => 'Modifier la Matière';

  @override
  String get subjectNameField => 'Nom de la matière (ex : Mathématiques)';

  @override
  String get coefficientField => 'Coefficient';

  @override
  String get noSubjects =>
      'Aucune matière pour l\'instant. Appuyez sur + pour en créer une.';

  @override
  String subjectSubtitle(Object className, Object coefficient) {
    return 'Classe : $className • Coefficient : $coefficient';
  }

  @override
  String get createClassFirst => 'Créez d\'abord une classe.';

  @override
  String get newStaffTitle => 'Nouvel Employé';

  @override
  String get fullNameField => 'Nom complet';

  @override
  String get positionField =>
      'Poste (ex : Secrétaire Général, Professeur de Mathématiques)';

  @override
  String get appAccessLabel => 'Accès à l\'application';

  @override
  String get roleTeacherOption => 'Professeur (notes, présences, devoirs)';

  @override
  String get roleAdminOption => 'Admin (accès complet)';

  @override
  String get createAccountButton => 'Créer le Compte';

  @override
  String get accountCreatedTitle => 'Compte créé';

  @override
  String get sendLinkToStaffBody =>
      'Envoyez ce lien à l\'employé pour qu\'il définisse son mot de passe :';

  @override
  String createAccountFailed(Object error) {
    return 'Impossible de créer le compte : $error';
  }

  @override
  String get noStaff =>
      'Aucun employé pour l\'instant. Appuyez sur + pour en ajouter un.';

  @override
  String get inactiveChip => 'Inactif';

  @override
  String get pendingTab => 'En attente';

  @override
  String get approvedTab => 'Approuvées';

  @override
  String get rejectedTab => 'Rejetées';

  @override
  String get newEnrollmentTitle => 'Nouvelle Demande d\'Inscription';

  @override
  String get studentFirstNameField => 'Prénom de l\'élève';

  @override
  String get studentLastNameField => 'Nom de famille de l\'élève';

  @override
  String get parentFullNameField => 'Nom complet du parent';

  @override
  String get parentEmailField => 'Email du parent';

  @override
  String get parentPhoneField => 'Téléphone du parent (optionnel)';

  @override
  String get submitButton => 'Soumettre';

  @override
  String get noRequests => 'Rien à afficher ici.';

  @override
  String parentSubtitle(Object name, Object email) {
    return 'Parent : $name • $email';
  }

  @override
  String get enrollmentApprovedTitle => 'Inscription approuvée';

  @override
  String get parentAccountCreatedBody =>
      'Le compte du parent a été créé. Envoyez-lui ce lien pour qu\'il définisse son mot de passe :';

  @override
  String get rejectTooltip => 'Rejeter';

  @override
  String get approveTooltip => 'Approuver';

  @override
  String get searchStudentHint => 'Rechercher un élève...';

  @override
  String get noActiveSchoolYear =>
      'Aucune année scolaire active pour le moment.';

  @override
  String get totalToPayLower => 'Total à payer';

  @override
  String get alreadyPaidLower => 'Déjà payé';

  @override
  String get remainingBalanceLower => 'Solde restant';

  @override
  String get notConfiguredChip => 'Non configuré';

  @override
  String get paidLabel => 'Payé';

  @override
  String get noMatchingStudents => 'Aucun élève ne correspond.';

  @override
  String get totalToPayTitle => 'Total à Payer';

  @override
  String get totalAmountField => 'Total (HTG) pour l\'année scolaire';

  @override
  String get recordInstallmentTitle => 'Enregistrer un Versement';

  @override
  String get monthField => 'Libellé (ex : Septembre 2026)';

  @override
  String get amountPaidField => 'Montant Payé (HTG)';

  @override
  String get invalidAmount => 'Montant invalide';

  @override
  String get paymentDateLabel => 'Date de Paiement';

  @override
  String get recordButton => 'Enregistrer';

  @override
  String get installmentRecordedTitle => 'Versement enregistré';

  @override
  String get printReceiptPrompt =>
      'Voulez-vous imprimer/partager le reçu maintenant ?';

  @override
  String get laterButton => 'Plus tard';

  @override
  String get printReceiptButton => 'Imprimer le Reçu';

  @override
  String get alreadyPaidTitle => 'Déjà Payé';

  @override
  String get editTotalDueButton => 'Modifier le Total à Payer';

  @override
  String get noInstallments => 'Aucun versement enregistré.';

  @override
  String paidOnLabel(Object date) {
    return 'Payé le : $date';
  }

  @override
  String get installmentFabLabel => 'Versement';

  @override
  String get notGradedYet => 'Pas encore de note';

  @override
  String overallAverageLabel(Object term, Object avg) {
    return 'Moyenne Générale ($term) : $avg/100';
  }

  @override
  String noGradesForTerm(Object term) {
    return 'Pas encore de notes pour $term';
  }

  @override
  String get exportReportCardButton => 'Exporter le Bulletin PDF';

  @override
  String get reportCardTab => 'Bulletin';

  @override
  String get feesTab => 'Frais';

  @override
  String get noStudentLinked => 'Ce compte n\'est lié à aucun dossier élève.';

  @override
  String get studentRecordNotFound => 'Dossier élève introuvable.';

  @override
  String get noChildrenLinked => 'Aucun enfant n\'est lié à ce compte.';

  @override
  String get myChildrenTitle => 'Mes Enfants';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String classIdSubtitle(Object classId) {
    return 'Classe : $classId';
  }

  @override
  String get termLabel => 'Période';

  @override
  String get typeLabel => 'Type';

  @override
  String get maxScoreField => 'Sur (max)';

  @override
  String get chooseClassAndSubject => 'Choisissez une classe et une matière.';

  @override
  String get noStudentsInClass => 'Aucun élève dans cette classe.';

  @override
  String get gradeHint => 'Note';

  @override
  String get saveGradesButton => 'Enregistrer les Notes';

  @override
  String gradesRecorded(Object count) {
    return '$count notes enregistrées.';
  }

  @override
  String get noAssignedClasses => 'Vous n\'avez pas encore de classe assignée.';

  @override
  String get statusPresent => 'Présent';

  @override
  String get statusAbsent => 'Absent';

  @override
  String get statusLate => 'En retard';

  @override
  String get statusExcused => 'Excusé';

  @override
  String get chooseClass => 'Choisissez une classe.';

  @override
  String get saveAttendanceButton => 'Enregistrer la Présence';

  @override
  String attendanceRecorded(Object count) {
    return 'Présence enregistrée pour $count élèves.';
  }

  @override
  String get newAssignmentTitle => 'Nouveau Devoir';

  @override
  String get titleField => 'Titre';

  @override
  String get descriptionField => 'Description';

  @override
  String get dueDateLabel => 'Échéance';

  @override
  String get sendAssignmentButton => 'Envoyer le Devoir';

  @override
  String get noAssignmentsYet =>
      'Aucun devoir pour l\'instant. Appuyez sur + pour en envoyer un.';

  @override
  String dueDatePrefix(Object date) {
    return 'Échéance : $date';
  }

  @override
  String get newMessageTitle => 'Nouveau Message';

  @override
  String get studentField => 'Élève';

  @override
  String get subjectField => 'Sujet';

  @override
  String get messageField => 'Message';

  @override
  String get sendButton => 'Envoyer';

  @override
  String get noLinkedStudentAccount =>
      'Cet élève n\'a pas de compte parent/élève lié.';

  @override
  String get noSentMessages =>
      'Aucun message envoyé pour l\'instant. Appuyez sur + pour en envoyer un.';

  @override
  String get noScheduledAssignments => 'Aucun devoir ou examen programmé.';

  @override
  String get noAttendanceRecords => 'Pas encore de dossier de présence.';

  @override
  String statusCountLabel(Object status, Object count) {
    return '$status : $count';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'Aucune notification.';

  @override
  String get noFeeInfo =>
      'Pas encore d\'informations de frais pour cette année scolaire.';

  @override
  String loadErrorMessage(Object error) {
    return 'Impossible de charger les données.\n$error';
  }
}
