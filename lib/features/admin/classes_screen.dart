import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/class_model.dart';
import '../../core/models/school_year.dart';
import '../../core/services/providers.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref,
    List<SchoolYear> years, {
    ClassModel? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name);
    final capacityController = TextEditingController(text: existing?.capacity.toString() ?? '');
    String? yearId = existing?.yearId ?? years.where((y) => y.active).firstOrNull?.id ?? years.firstOrNull?.id;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Nouvo Klas' : 'Modifye Klas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Non klas (eg: 7èm AF)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: yearId,
                decoration: const InputDecoration(labelText: 'Ane Lekòl'),
                items: years
                    .map((y) => DropdownMenuItem(value: y.id, child: Text(y.label)))
                    .toList(),
                onChanged: (v) => setState(() => yearId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Kapasite (opsyonèl)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anile')),
            FilledButton(
              onPressed: yearId == null
                  ? null
                  : () async {
                      final id = existing?.id ?? ref.read(firestoreProvider).collection('classes').doc().id;
                      await ref.read(firestoreServiceProvider).saveClass(
                            ClassModel(
                              id: id,
                              name: nameController.text.trim(),
                              yearId: yearId!,
                              headTeacherUid: existing?.headTeacherUid,
                              capacity: int.tryParse(capacityController.text) ?? 0,
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
      body: StreamBuilder<List<SchoolYear>>(
        stream: ref.watch(firestoreServiceProvider).watchSchoolYears(),
        builder: (context, yearSnapshot) {
          final years = yearSnapshot.data ?? const [];
          return StreamBuilder<List<ClassModel>>(
            stream: ref.watch(firestoreServiceProvider).watchClasses(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final classes = snapshot.data!;
              if (classes.isEmpty) {
                return const Center(child: Text('Poko gen klas. Peze + pou kreye youn.'));
              }
              return ListView.builder(
                itemCount: classes.length,
                itemBuilder: (context, i) {
                  final c = classes[i];
                  final yearLabel = years.where((y) => y.id == c.yearId).firstOrNull?.label ?? c.yearId;
                  return ListTile(
                    leading: const Icon(Icons.class_outlined),
                    title: Text(c.name),
                    subtitle: Text('Ane: $yearLabel${c.capacity > 0 ? ' • Kapasite: ${c.capacity}' : ''}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) async {
                        if (action == 'edit') {
                          await _openForm(context, ref, years, existing: c);
                        } else if (action == 'delete') {
                          await ref.read(firestoreServiceProvider).deleteClass(c.id);
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
      floatingActionButton: StreamBuilder<List<SchoolYear>>(
        stream: ref.watch(firestoreServiceProvider).watchSchoolYears(),
        builder: (context, snapshot) {
          final years = snapshot.data ?? const [];
          return FloatingActionButton(
            onPressed: years.isEmpty
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kreye yon ane lekòl anvan.')),
                    )
                : () => _openForm(context, ref, years),
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
