import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/grade.dart';
import 'grade_calculator.dart';

/// Builds a one-page report card (bilten) as PDF bytes for one student/term,
/// ready to hand to `Printing.layoutPdf`/`Printing.sharePdf` from the
/// `printing` package. Mirrors the on-screen breakdown in GradesReportView.
Future<Uint8List> buildReportCardPdf({
  required String schoolName,
  required String studentName,
  required String className,
  required String yearLabel,
  required String term,
  required List<SubjectTermSummary> subjects,
  required double? overallAverage,
}) async {
  final doc = pw.Document();
  final dateFormat = DateFormat('dd/MM/yyyy');

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(32),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(schoolName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Bilten Nòt', style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 4),
            pw.Divider(),
            pw.SizedBox(height: 12),
            _row('Elèv', studentName),
            _row('Klas', className),
            _row('Ane Lekòl', yearLabel),
            _row('Peryòd', term),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(3),
                3: pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _cell('Matyè', bold: true),
                    _cell('Kwef.', bold: true),
                    _cell('Nòt', bold: true),
                    _cell('Mwayèn /100', bold: true),
                  ],
                ),
                for (final s in subjects)
                  pw.TableRow(
                    children: [
                      _cell(s.subjectName),
                      _cell(s.coefficient.toStringAsFixed(0)),
                      _cell(s.entries.isEmpty
                          ? 'Poko gen nòt'
                          : s.entries
                              .map((g) => '${g.type.value}: ${g.value.toStringAsFixed(0)}/${g.maxValue.toStringAsFixed(0)}')
                              .join(', ')),
                      _cell(s.average != null ? s.average!.toStringAsFixed(1) : '-'),
                    ],
                  ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                overallAverage != null
                    ? 'Mwayèn Jeneral ($term): ${overallAverage.toStringAsFixed(1)}/100'
                    : 'Poko gen nòt pou $term',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
                textAlign: pw.TextAlign.center,
              ),
            ),
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

pw.Widget _row(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      children: [
        pw.SizedBox(width: 90, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        pw.Text(value),
      ],
    ),
  );
}

pw.Widget _cell(String text, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 10),
    ),
  );
}
