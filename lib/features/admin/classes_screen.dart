import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/class_model.dart';
import '../../core/models/school_year.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import '../shared/async_error_view.dart';

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
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? l10n.newClass : l10n.editClass),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.classNameField),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: yearId,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.navSchoolYears),
                  items: years
                      .map((y) => DropdownMenuItem(value: y.id, child: Text(y.label, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => yearId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: capacityController,
                  decoration: InputDecoration(labelText: l10n.capacityField),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
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
      body: StreamBuilder<List<SchoolYear>>(
        stream: ref.watch(firestoreServiceProvider).watchSchoolYears(),
        builder: (context, yearSnapshot) {
          final years = yearSnapshot.data ?? const [];
          return StreamBuilder<List<ClassModel>>(
            stream: ref.watch(firestoreServiceProvider).watchClasses(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return AsyncErrorView(error: snapshot.error);
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final classes = snapshot.data!;
              if (classes.isEmpty) {
                return Center(child: Text(l10n.noClasses));
              }
              return ListView.builder(
                itemCount: classes.length,
                itemBuilder: (context, i) {
                  final c = classes[i];
                  final yearLabel = years.where((y) => y.id == c.yearId).firstOrNull?.label ?? c.yearId;
                  return ListTile(
                    leading: const Icon(Icons.class_outlined),
                    title: Text(c.name),
                    subtitle: Text(c.capacity > 0
                        ? l10n.classSubtitleYearCapacity(yearLabel, c.capacity)
                        : l10n.classSubtitleYear(yearLabel)),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) async {
                        if (action == 'edit') {
                          await _openForm(context, ref, years, existing: c);
                        } else if (action == 'delete') {
                          await ref.read(firestoreServiceProvider).deleteClass(c.id);
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
      floatingActionButton: StreamBuilder<List<SchoolYear>>(
        stream: ref.watch(firestoreServiceProvider).watchSchoolYears(),
        builder: (context, snapshot) {
          final years = snapshot.data ?? const [];
          return FloatingActionButton(
            onPressed: years.isEmpty
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.createYearFirst)),
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
