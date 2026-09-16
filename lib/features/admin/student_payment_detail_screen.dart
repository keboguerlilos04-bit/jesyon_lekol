import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../core/models/class_model.dart';
import '../../core/models/payment_record.dart';
import '../../core/models/school_year.dart';
import '../../core/models/student.dart';
import '../../core/services/providers.dart';
import '../../core/services/receipt_pdf.dart';

const _schoolName = 'Jesyon Lekòl';

class StudentPaymentDetailScreen extends ConsumerWidget {
  const StudentPaymentDetailScreen({super.key, required this.student, required this.year});

  final Student student;
  final SchoolYear year;

  Future<void> _editTotalDue(BuildContext context, WidgetRef ref, double currentTotal) async {
    final controller = TextEditingController(text: currentTotal > 0 ? currentTotal.toStringAsFixed(0) : '');
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Total pou Peye'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Total (HTG) pou ane lekòl la'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anile')),
          FilledButton(
            onPressed: () async {
              final total = double.tryParse(controller.text);
              if (total == null) return;
              final adminUid = ref.read(firebaseAuthProvider).currentUser!.uid;
              await ref.read(firestoreServiceProvider).setPaymentTotalDue(
                    studentId: student.id,
                    yearId: year.id,
                    totalDue: total,
                    updatedBy: adminUid,
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Sove'),
          ),
        ],
      ),
    );
  }

  Future<void> _addInstallment(BuildContext context, WidgetRef ref, String className) async {
    final formKey = GlobalKey<FormState>();
    final monthController = TextEditingController();
    final amountController = TextEditingController();
    DateTime paidAt = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Anrejistre yon Vèsman'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: monthController,
                  decoration: const InputDecoration(labelText: 'Etikèt (eg: Septanm 2026)'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Obligatwa' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Montan Peye (HTG)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Montan envalid' : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dat Peman'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(paidAt)),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: paidAt,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => paidAt = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anile')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final adminUid = ref.read(firebaseAuthProvider).currentUser!.uid;
                final installment = Installment(
                  month: monthController.text.trim(),
                  amount: double.parse(amountController.text),
                  paidAt: paidAt,
                );
                final updated = await ref.read(firestoreServiceProvider).recordPaymentInstallment(
                      studentId: student.id,
                      yearId: year.id,
                      installment: installment,
                      updatedBy: adminUid,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  _offerReceipt(context, installment, updated, className);
                }
              },
              child: const Text('Anrejistre'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _offerReceipt(
    BuildContext context,
    Installment installment,
    PaymentRecord payment,
    String className,
  ) async {
    final print = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vèsman anrejistre'),
        content: const Text('Ou vle enprime/pataje resi a kounye a?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Pita')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enprime Resi')),
        ],
      ),
    );
    if (print == true) {
      await _printReceipt(installment, payment, className);
    }
  }

  Future<void> _printReceipt(Installment installment, PaymentRecord payment, String className) {
    return Printing.layoutPdf(
      onLayout: (format) => buildPaymentReceiptPdf(
        schoolName: _schoolName,
        studentName: student.fullName,
        className: className,
        yearLabel: year.label,
        installment: installment,
        totalDue: payment.totalDue,
        amountPaid: payment.amountPaid,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.currency(symbol: 'HTG ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return StreamBuilder<List<ClassModel>>(
      stream: ref.watch(firestoreServiceProvider).watchClassesByIds([student.classId]),
      builder: (context, classSnap) {
        final className = classSnap.data?.firstOrNull?.name ?? student.classId;

        return Scaffold(
          appBar: AppBar(title: Text(student.fullName)),
          body: StreamBuilder<PaymentRecord?>(
            stream: ref.watch(firestoreServiceProvider).watchPayment(student.id, year.id),
            builder: (context, snapshot) {
              final payment = snapshot.data;
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Column(
                      children: [
                        _summaryRow('Total pou Peye', currency.format(payment?.totalDue ?? 0)),
                        _summaryRow('Deja Peye', currency.format(payment?.amountPaid ?? 0)),
                        const Divider(),
                        _summaryRow('Rès pou Peye', currency.format(payment?.balance ?? 0), emphasize: true),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _editTotalDue(context, ref, payment?.totalDue ?? 0),
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifye Total pou Peye'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: (payment == null || payment.installments.isEmpty)
                        ? const Center(child: Text('Pa gen vèsman anrejistre.'))
                        : ListView.builder(
                            itemCount: payment.installments.length,
                            itemBuilder: (context, i) {
                              final installment = payment.installments[i];
                              return ListTile(
                                leading: const Icon(Icons.check_circle, color: Colors.green),
                                title: Text(installment.month),
                                subtitle: installment.paidAt != null
                                    ? Text('Peye: ${dateFormat.format(installment.paidAt!)}')
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(currency.format(installment.amount)),
                                    IconButton(
                                      icon: const Icon(Icons.print_outlined),
                                      tooltip: 'Enprime Resi',
                                      onPressed: () => _printReceipt(installment, payment, className),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addInstallment(context, ref, className),
            icon: const Icon(Icons.add),
            label: const Text('Vèsman'),
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: emphasize ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
              fontSize: emphasize ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
