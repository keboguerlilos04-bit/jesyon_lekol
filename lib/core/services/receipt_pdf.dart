import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/payment_record.dart';

/// Builds a one-page payment receipt as PDF bytes, ready to hand to
/// `Printing.layoutPdf`/`Printing.sharePdf` from the `printing` package.
Future<Uint8List> buildPaymentReceiptPdf({
  required String schoolName,
  required String studentName,
  required String className,
  required String yearLabel,
  required Installment installment,
  required double totalDue,
  required double amountPaid,
}) async {
  final doc = pw.Document();
  final balance = totalDue - amountPaid;
  final currency = NumberFormat.currency(symbol: 'HTG ', decimalDigits: 0);
  final dateFormat = DateFormat('dd/MM/yyyy');

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(28),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(schoolName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Resi Peman Frè Skolaris', style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 4),
            pw.Divider(),
            pw.SizedBox(height: 12),
            _row('Elèv', studentName),
            _row('Klas', className),
            _row('Ane Lekòl', yearLabel),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.SizedBox(height: 12),
            _row('Vèsman pou', installment.month),
            _row('Montan Peye', currency.format(installment.amount)),
            _row('Dat Peman', installment.paidAt != null ? dateFormat.format(installment.paidAt!) : '-'),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.SizedBox(height: 12),
            _row('Total pou Peye (Ane a)', currency.format(totalDue)),
            _row('Total Deja Peye', currency.format(amountPaid)),
            pw.SizedBox(height: 4),
            _row('Rès pou Peye', currency.format(balance), bold: true),
            pw.Spacer(),
            pw.Text(
              'Jenere ${dateFormat.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    ),
  );

  return doc.save();
}

pw.Widget _row(String label, String value, {bool bold = false}) {
  final style = pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text(value, style: style),
      ],
    ),
  );
}
