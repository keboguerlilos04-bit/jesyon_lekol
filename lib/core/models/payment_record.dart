import 'package:cloud_firestore/cloud_firestore.dart';

class Installment {
  final String month;
  final double amount;
  final DateTime? paidAt;
  final String? receiptUrl;

  const Installment({
    required this.month,
    required this.amount,
    this.paidAt,
    this.receiptUrl,
  });

  factory Installment.fromMap(Map<String, dynamic> map) {
    return Installment(
      month: map['month'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      paidAt: (map['paidAt'] as Timestamp?)?.toDate(),
      receiptUrl: map['receiptUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'amount': amount,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'receiptUrl': receiptUrl,
    };
  }
}

/// Mirrors a document in /payments/{paymentId}.
/// Only admin (via Cloud Function or a rule restricted to role == 'admin')
/// may write. Parents/students only ever read their own balance.
class PaymentRecord {
  final String id;
  final String studentId;
  final String yearId;
  final double totalDue;
  final double amountPaid;
  final List<Installment> installments;
  final String updatedBy;

  const PaymentRecord({
    required this.id,
    required this.studentId,
    required this.yearId,
    required this.totalDue,
    required this.amountPaid,
    required this.installments,
    required this.updatedBy,
  });

  double get balance => totalDue - amountPaid;

  factory PaymentRecord.fromMap(String id, Map<String, dynamic> map) {
    return PaymentRecord(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      yearId: map['yearId'] as String? ?? '',
      totalDue: (map['totalDue'] as num?)?.toDouble() ?? 0,
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0,
      installments: ((map['installments'] as List?) ?? const [])
          .map((e) => Installment.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      updatedBy: map['updatedBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'yearId': yearId,
      'totalDue': totalDue,
      'amountPaid': amountPaid,
      'installments': installments.map((i) => i.toMap()).toList(),
      'updatedBy': updatedBy,
    };
  }
}
