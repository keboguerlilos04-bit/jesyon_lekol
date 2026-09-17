import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/school_year.dart';
import '../../core/services/providers.dart';
import '../../l10n/app_localizations.dart';
import '../shared/async_error_view.dart';

class SchoolYearsScreen extends ConsumerWidget {
  const SchoolYearsScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {SchoolYear? existing}) async {
    final labelController = TextEditingController(text: existing?.label);
    DateTime start = existing?.startDate ?? DateTime(DateTime.now().year, 9, 1);
    DateTime end = existing?.endDate ?? DateTime(DateTime.now().year + 1, 6, 30);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? l10n.newSchoolYear : l10n.editSchoolYear),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(labelText: l10n.yearLabelField),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.startDateLabel),
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
                  title: Text(l10n.endDateLabel),
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
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
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
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: StreamBuilder<List<SchoolYear>>(
        stream: ref.watch(firestoreServiceProvider).watchSchoolYears(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return AsyncErrorView(error: snapshot.error);
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final years = snapshot.data!;
          if (years.isEmpty) {
            return Center(child: Text(l10n.noSchoolYears));
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
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    if (!y.active) PopupMenuItem(value: 'activate', child: Text(l10n.activate)),
                    PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
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
