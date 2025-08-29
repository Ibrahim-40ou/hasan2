import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hasan2/models/installment_model.dart';

class Debt {
  final String? id;
  final String personName;
  final double totalAmount;
  final DateTime startDate;
  final List<Installment> installments;
  final bool isFinished;
  final DateTime? endDate;
  final String note;
  final String phoneNumber;

  Debt({
    this.id,
    required this.personName,
    required this.totalAmount,
    required this.startDate,
    required this.installments,
    this.isFinished = false,
    this.endDate,
    required this.note,
    required this.phoneNumber,
  });

  factory Debt.fromJson(Map<String, dynamic> json, String id) {
    return Debt(
      id: id,
      personName: json['personName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      startDate: (json['startDate'] as Timestamp).toDate(),
      installments: (json['installments'] as List<dynamic>).map((e) => Installment.fromJson(e as Map<String, dynamic>)).toList(),
      isFinished: json['isFinished'] as bool,
      endDate: (json['endDate'] as Timestamp?)?.toDate(),
      note: json['note'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personName': personName,
      'totalAmount': totalAmount,
      'startDate': Timestamp.fromDate(startDate),
      'installments': installments.map((e) => e.toJson()).toList(),
      'isFinished': isFinished,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'note': note,
      'phoneNumber': phoneNumber,
    };
  }

  Debt copyWith({
    String? id,
    String? personName,
    double? totalAmount,
    DateTime? startDate,
    List<Installment>? installments,
    bool? isFinished,
    DateTime? endDate,
    String? note,
    String? phoneNumber,
  }) {
    return Debt(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      totalAmount: totalAmount ?? this.totalAmount,
      startDate: startDate ?? this.startDate,
      installments: installments ?? this.installments,
      isFinished: isFinished ?? this.isFinished,
      endDate: endDate ?? this.endDate,
      note: note ?? this.note,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
