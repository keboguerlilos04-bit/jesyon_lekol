import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/class_model.dart';
import '../../core/models/subject.dart';
import '../../core/services/providers.dart';

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

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Nouvo Matyè' : 'Modifye Matyè'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Non matyè (eg: Matematik)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: classId,
                decoration: const InputDecoration(labelText: 'Klas'),
                items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => classId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: coefficientController,
                decoration: const InputDecoration(labelText: 'Kowefisyan'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anile')),
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
              child: const Text('Sove'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: StreamBuilder<List<ClassModel>>(
        stream: ref.watch(firestoreServiceProvider).watchClasses(),
        builder: (context, classSnapshot) {
          final classes = classSnapshot.data ?? const [];
          return StreamBuilder<List<Subject>>(
            stream: ref.watch(firestoreServiceProvider).watchSubjects(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final subjects = snapshot.data!;
              if (subjects.isEmpty) {
                return const Center(child: Text('Poko gen matyè. Peze + pou kreye youn.'));
              }
              return ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, i) {
                  final s = subjects[i];
                  final className = classes.where((c) => c.id == s.classId).firstOrNull?.name ?? s.classId;
                  return ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(s.name),
                    subtitle: Text('Klas: $className • Kowefisyan: ${s.coefficient}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) async {
                        if (action == 'edit') {
                          await _openForm(context, ref, classes, existing: s);
                        } else if (action == 'delete') {
                          await ref.read(firestoreServiceProvider).deleteSubject(s.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Modifye')),
                        const PopupMenuItem(value: 'delete', child: Text('Efase')),
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
                      const SnackBar(content: Text('Kreye yon klas anvan.')),
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
