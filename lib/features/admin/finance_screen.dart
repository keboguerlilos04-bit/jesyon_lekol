import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/class_model.dart';
import '../../core/models/payment_record.dart';
import '../../core/models/student.dart';
import '../../core/services/providers.dart';
import 'student_payment_detail_screen.dart';

/// Admin/secretary view of every student's fee balance for the active
/// school year — the "rapò sou balans ki rete" from the spec. Tapping a row
/// opens the detail screen to set the amount owed and record payments.
class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final activeYearAsync = ref.watch(activeSchoolYearProvider);
    final currency = NumberFormat.currency(symbol: 'HTG ', decimalDigits: 0);

    return activeYearAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erè: $e')),
      data: (year) {
        if (year == null) {
          return const Center(child: Text('Pa gen ane lekòl aktif kounye a.'));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Chèche yon elèv...',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Student>>(
                stream: ref.watch(firestoreServiceProvider).watchAllStudents(),
                builder: (context, studentSnap) {
                  final students = studentSnap.data ?? const <Student>[];
                  return StreamBuilder<List<ClassModel>>(
                    stream: ref.watch(firestoreServiceProvider).watchClasses(yearId: year.id),
                    builder: (context, classSnap) {
                      final classes = {for (final c in classSnap.data ?? const <ClassModel>[]) c.id: c.name};
                      return StreamBuilder<List<PaymentRecord>>(
                        stream: ref.watch(firestoreServiceProvider).watchPaymentsForYear(year.id),
                        builder: (context, paymentSnap) {
                          if (!studentSnap.hasData || !paymentSnap.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final paymentsByStudent = {
                            for (final p in paymentSnap.data!) p.studentId: p,
                          };

                          final visible = students
                              .where((s) => classes.containsKey(s.classId))
                              .where((s) => _search.isEmpty || s.fullName.toLowerCase().contains(_search))
                              .toList();

                          if (visible.isEmpty) {
                            return const Center(child: Text('Pa gen elèv ki koresponn.'));
                          }

                          return ListView.builder(
                            itemCount: visible.length,
                            itemBuilder: (context, i) {
                              final student = visible[i];
                              final payment = paymentsByStudent[student.id];
                              final balance = payment?.balance;
                              return ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                                title: Text(student.fullName),
                                subtitle: Text(classes[student.classId] ?? student.classId),
                                trailing: balance == null
                                    ? const Chip(label: Text('Poko konfigire'))
                                    : Text(
                                        balance <= 0 ? 'Peye' : currency.format(balance),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: balance <= 0 ? Colors.green : Colors.red,
                                        ),
                                      ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StudentPaymentDetailScreen(student: student, year: year),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
