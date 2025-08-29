import 'package:cloud_firestore/cloud_firestore.dart';

class Installment {
  final double amount;
  final DateTime dueDate;

  Installment({required this.amount, required this.dueDate});

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(amount: (json['amount'] as num).toDouble(), dueDate: (json['dueDate'] as Timestamp).toDate());
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'dueDate': Timestamp.fromDate(dueDate)};
  }

  Installment copyWith({double? amount, DateTime? dueDate, bool? isPaid}) {
    return Installment(amount: amount ?? this.amount, dueDate: dueDate ?? this.dueDate);
  }
}
