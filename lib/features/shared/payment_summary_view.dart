import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/payment_record.dart';
import '../../core/services/providers.dart';

/// Read-only balance + installment history for one student's school fees.
/// All writes (recording a payment) go through the admin-only Finance
/// module — a parent never has a write path to this collection.
class PaymentSummaryView extends ConsumerWidget {
  const PaymentSummaryView({super.key, required this.studentId, required this.yearId});

  final String studentId;
  final String yearId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.currency(symbol: 'HTG ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return StreamBuilder<PaymentRecord?>(
      stream: ref.watch(firestoreServiceProvider).watchPayment(studentId, yearId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final payment = snapshot.data;
        if (payment == null) {
          return const Center(child: Text('Poko gen enfòmasyon frè pou ane lekòl sa a.'));
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                children: [
                  _summaryRow('Total pou peye', currency.format(payment.totalDue)),
                  _summaryRow('Deja peye', currency.format(payment.amountPaid)),
                  const Divider(),
                  _summaryRow(
                    'Rès pou peye',
                    currency.format(payment.balance),
                    emphasize: true,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: payment.installments.isEmpty
                  ? const Center(child: Text('Pa gen vèsman anrejistre.'))
                  : ListView.builder(
                      itemCount: payment.installments.length,
                      itemBuilder: (context, i) {
                        final installment = payment.installments[i];
                        final paid = installment.paidAt != null;
                        return ListTile(
                          leading: Icon(
                            paid ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: paid ? Colors.green : null,
                          ),
                          title: Text(installment.month),
                          subtitle: paid ? Text('Peye: ${dateFormat.format(installment.paidAt!)}') : null,
                          trailing: Text(currency.format(installment.amount)),
                        );
                      },
                    ),
            ),
          ],
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
