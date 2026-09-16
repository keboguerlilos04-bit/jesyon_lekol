import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/school_year.dart';
import '../../core/services/providers.dart';

class SchoolYearsScreen extends ConsumerWidget {
  const SchoolYearsScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {SchoolYear? existing}) async {
    final labelController = TextEditingController(text: existing?.label);
    DateTime start = existing?.startDate ?? DateTime(DateTime.now().year, 9, 1);
    DateTime end = existing?.endDate ?? DateTime(DateTime.now().year + 1, 6, 30);
    final dateFormat = DateFormat('dd/MM/yyyy');

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Nouvo Ane Lekòl' : 'Modifye Ane Lekòl'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Etikèt (eg: 2026-2027)'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Kòmansman'),
                subtitle: Text(dateFormat.format(start)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: start,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => start = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fen'),
                subtitle: Text(dateFormat.format(end)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: end,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => end = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anile')),
            FilledButton(
              onPressed: () async {
                final id = existing?.id ??
                    ref.read(firestoreProvider).collection('schoolYears').doc().id;
                await ref.read(firestoreServiceProvider).saveSchoolYear(
                      SchoolYear(
                        id: id,
                        label: labelController.text.trim(),
                        startDate: start,
                        endDate: end,
                        active: existing?.active ?? false,
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
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Scaffold(
      body: StreamBuilder<List<SchoolYear>>(
        stream: ref.watch(firestoreServiceProvider).watchSchoolYears(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final years = snapshot.data!;
          if (years.isEmpty) {
            return const Center(child: Text('Poko gen ane lekòl. Peze + pou kreye youn.'));
          }
          return ListView.builder(
            itemCount: years.length,
            itemBuilder: (context, i) {
              final y = years[i];
              return ListTile(
                leading: Icon(
                  y.active ? Icons.check_circle : Icons.circle_outlined,
                  color: y.active ? Colors.green : null,
                ),
                title: Text(y.label),
                subtitle: Text('${dateFormat.format(y.startDate)} - ${dateFormat.format(y.endDate)}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) async {
                    if (action == 'edit') {
                      await _openForm(context, ref, existing: y);
                    } else if (action == 'activate') {
                      await ref.read(firestoreServiceProvider).setActiveSchoolYear(y.id);
                    } else if (action == 'delete') {
                      await ref.read(firestoreServiceProvider).deleteSchoolYear(y.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Modifye')),
                    if (!y.active) const PopupMenuItem(value: 'activate', child: Text('Aktive')),
                    const PopupMenuItem(value: 'delete', child: Text('Efase')),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
