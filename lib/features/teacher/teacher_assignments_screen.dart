import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/assignment.dart';
import '../../core/models/class_model.dart';
import '../../core/models/subject.dart';
import '../../core/services/providers.dart';

class TeacherAssignmentsScreen extends ConsumerWidget {
  const TeacherAssignmentsScreen({super.key});

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref,
    List<ClassModel> classes,
    List<Subject> subjects,
  ) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? classId = classes.firstOrNull?.id;
    String? subjectId = subjects.where((s) => s.classId == classId).firstOrNull?.id;
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final subjectsForClass = subjects.where((s) => s.classId == classId).toList();
          if (subjectId == null || !subjectsForClass.any((s) => s.id == subjectId)) {
            subjectId = subjectsForClass.firstOrNull?.id;
          }
          return AlertDialog(
            title: const Text('Nouvo Devwa'),
            content: SizedBox(
              width: 420,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Tit'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Obligatwa' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Deskripsyon'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: classId,
                        decoration: const InputDecoration(labelText: 'Klas'),
                        items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (v) => setState(() => classId = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: subjectId,
                        decoration: const InputDecoration(labelText: 'Matyè'),
                        items: subjectsForClass
                            .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                            .toList(),
                        onChanged: (v) => setState(() => subjectId = v),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Delè'),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(dueDate)),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 1)),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => dueDate = picked);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anile')),
              FilledButton(
                onPressed: (classId == null || subjectId == null)
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        final teacherUid = ref.read(firebaseAuthProvider).currentUser!.uid;
                        final id = ref.read(firestoreProvider).collection('assignments').doc().id;
                        await ref.read(firestoreServiceProvider).createAssignment(
                              Assignment(
                                id: id,
                                classId: classId!,
                                subjectId: subjectId!,
                                teacherUid: teacherUid,
                                title: titleController.text.trim(),
                                description: descriptionController.text.trim(),
                                dueDate: dueDate,
                              ),
                            );
                        if (context.mounted) Navigator.pop(context);
                      },
                child: const Text('Voye Devwa'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacherProfileAsync = ref.watch(currentTeacherProfileProvider);
    final teacherUid = ref.watch(firebaseAuthProvider).currentUser?.uid ?? '';
    final dateFormat = DateFormat('dd/MM/yyyy');

    return teacherProfileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erè: $e')),
      data: (profile) {
        final classIds = profile?.classIds ?? const [];
        final subjectIds = profile?.subjectIds ?? const [];
        return Scaffold(
          body: StreamBuilder<List<Assignment>>(
            stream: ref.watch(firestoreServiceProvider).watchAssignmentsByTeacher(teacherUid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final assignments = snapshot.data!;
              if (assignments.isEmpty) {
                return const Center(child: Text('Poko gen devwa. Peze + pou voye youn.'));
              }
              return ListView.builder(
                itemCount: assignments.length,
                itemBuilder: (context, i) {
                  final a = assignments[i];
                  return ListTile(
                    leading: const Icon(Icons.assignment_outlined),
                    title: Text(a.title),
                    subtitle: Text('Delè: ${dateFormat.format(a.dueDate)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref.read(firestoreServiceProvider).deleteAssignment(a.id),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: StreamBuilder<List<ClassModel>>(
            stream: ref.watch(firestoreServiceProvider).watchClassesByIds(classIds),
            builder: (context, classSnap) {
              return StreamBuilder<List<Subject>>(
                stream: ref.watch(firestoreServiceProvider).watchSubjectsByIds(subjectIds),
                builder: (context, subjectSnap) {
                  final classes = classSnap.data ?? const [];
                  final subjects = subjectSnap.data ?? const [];
                  return FloatingActionButton(
                    onPressed: classes.isEmpty
                        ? () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Ou poko gen klas ki asiyen a ou.')))
                        : () => _openForm(context, ref, classes, subjects),
                    child: const Icon(Icons.add),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
