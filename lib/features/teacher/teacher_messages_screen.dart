import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/class_model.dart';
import '../../core/models/message.dart';
import '../../core/models/student.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import '../shared/async_error_view.dart';

class TeacherMessagesScreen extends ConsumerStatefulWidget {
  const TeacherMessagesScreen({super.key});

  @override
  ConsumerState<TeacherMessagesScreen> createState() => _TeacherMessagesScreenState();
}

class _TeacherMessagesScreenState extends ConsumerState<TeacherMessagesScreen> {
  Future<void> _openComposeForm(
    BuildContext context,
    List<ClassModel> classes,
  ) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String? classId = classes.isEmpty ? null : classes.first.id;
    Student? selectedStudent;
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.newMessageTitle),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: classId,
                      decoration: InputDecoration(labelText: l10n.classLabel),
                      items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (v) => setState(() {
                        classId = v;
                        selectedStudent = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (classId != null)
                      StreamBuilder<List<Student>>(
                        stream: ref.read(firestoreServiceProvider).watchStudentsByClass(classId!),
                        builder: (context, snapshot) {
                          final roster = snapshot.data ?? const <Student>[];
                          selectedStudent ??= roster.isEmpty ? null : roster.first;
                          return DropdownButtonFormField<Student>(
                            initialValue: selectedStudent,
                            decoration: InputDecoration(labelText: l10n.studentField),
                            items: roster
                                .map((s) => DropdownMenuItem(value: s, child: Text(s.fullName)))
                                .toList(),
                            onChanged: (v) => setState(() => selectedStudent = v),
                          );
                        },
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: l10n.subjectField),
                      validator: (v) => (v == null || v.isEmpty) ? l10n.required : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: bodyController,
                      decoration: InputDecoration(labelText: l10n.messageField),
                      maxLines: 4,
                      validator: (v) => (v == null || v.isEmpty) ? l10n.required : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: (classId == null || selectedStudent == null)
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final student = selectedStudent!;
                      final recipientUids = <String>{
                        ...student.parentIds,
                        if (student.uid != null) student.uid!,
                      }.toList();
                      if (recipientUids.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.noLinkedStudentAccount)),
                        );
                        return;
                      }
                      final teacherUid = ref.read(firebaseAuthProvider).currentUser!.uid;
                      final id = ref.read(firestoreProvider).collection('messages').doc().id;
                      await ref.read(firestoreServiceProvider).sendMessage(
                            Message(
                              id: id,
                              fromUid: teacherUid,
                              studentId: student.id,
                              classId: classId!,
                              recipientUids: recipientUids,
                              title: titleController.text.trim(),
                              body: bodyController.text.trim(),
                            ),
                          );
                      if (context.mounted) Navigator.pop(context);
                    },
              child: Text(l10n.sendButton),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teacherUid = ref.watch(firebaseAuthProvider).currentUser?.uid ?? '';
    final teacherProfileAsync = ref.watch(currentTeacherProfileProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: StreamBuilder<List<Message>>(
        stream: ref.watch(firestoreServiceProvider).watchSentMessages(teacherUid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return AsyncErrorView(error: snapshot.error);
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final messages = snapshot.data!;
          if (messages.isEmpty) {
            return Center(child: Text(l10n.noSentMessages));
          }
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final m = messages[i];
              return ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(m.title),
                subtitle: Text(m.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: m.sentAt != null ? Text(dateFormat.format(m.sentAt!)) : null,
              );
            },
          );
        },
      ),
      floatingActionButton: teacherProfileAsync.when(
        loading: () => null,
        error: (e, _) => null,
        data: (profile) {
          final classIds = profile?.classIds ?? const [];
          return StreamBuilder<List<ClassModel>>(
            stream: ref.watch(firestoreServiceProvider).watchClassesByIds(classIds),
            builder: (context, snapshot) {
              final classes = snapshot.data ?? const [];
              return FloatingActionButton(
                onPressed: classes.isEmpty
                    ? () => ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(l10n.noAssignedClasses)))
                    : () => _openComposeForm(context, classes),
                child: const Icon(Icons.edit),
              );
            },
          );
        },
      ),
    );
  }
}
