import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/class_model.dart';
import '../../core/models/subject.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import '../shared/async_error_view.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref,
    List<ClassModel> classes, {
    Subject? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name);
    final coefficientController =
        TextEditingController(text: existing?.coefficient.toString() ?? '1');
    String? classId = existing?.classId ?? classes.firstOrNull?.id;
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? l10n.newSubject : l10n.editSubject),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.subjectNameField),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: classId,
                  decoration: InputDecoration(labelText: l10n.classLabel),
                  items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => classId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: coefficientController,
                  decoration: InputDecoration(labelText: l10n.coefficientField),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: classId == null
                  ? null
                  : () async {
                      final id = existing?.id ?? ref.read(firestoreProvider).collection('subjects').doc().id;
                      await ref.read(firestoreServiceProvider).saveSubject(
                            Subject(
                              id: id,
                              name: nameController.text.trim(),
                              coefficient: double.tryParse(coefficientController.text) ?? 1,
                              classId: classId!,
                            ),
                          );
                      if (context.mounted) Navigator.pop(context);
                    },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: StreamBuilder<List<ClassModel>>(
        stream: ref.watch(firestoreServiceProvider).watchClasses(),
        builder: (context, classSnapshot) {
          final classes = classSnapshot.data ?? const [];
          return StreamBuilder<List<Subject>>(
            stream: ref.watch(firestoreServiceProvider).watchSubjects(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return AsyncErrorView(error: snapshot.error);
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final subjects = snapshot.data!;
              if (subjects.isEmpty) {
                return Center(child: Text(l10n.noSubjects));
              }
              return ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, i) {
                  final s = subjects[i];
                  final className = classes.where((c) => c.id == s.classId).firstOrNull?.name ?? s.classId;
                  return ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(s.name),
                    subtitle: Text(l10n.subjectSubtitle(className, s.coefficient)),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) async {
                        if (action == 'edit') {
                          await _openForm(context, ref, classes, existing: s);
                        } else if (action == 'delete') {
                          await ref.read(firestoreServiceProvider).deleteSubject(s.id);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                        PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<List<ClassModel>>(
        stream: ref.watch(firestoreServiceProvider).watchClasses(),
        builder: (context, snapshot) {
          final classes = snapshot.data ?? const [];
          return FloatingActionButton(
            onPressed: classes.isEmpty
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.createClassFirst)),
                    )
                : () => _openForm(context, ref, classes),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
