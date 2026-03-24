import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final double amount;
  final DateTime month;
  final String userId;

  Budget({
    required this.id,
    required this.amount,
    required this.month,
    required this.userId,
  });

  Budget copyWith({
    String? id,
    double? amount,
    DateTime? month,
    String? userId,
  }) {
    return Budget(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'month': DateTime(month.year, month.month, 1).toUtc(),
      'userId': userId,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    final monthData = map['month'];
    DateTime parsedMonth;
    if (monthData is Timestamp) {
      parsedMonth = monthData.toDate();
    } else {
      parsedMonth = DateTime.tryParse(monthData.toString()) ?? DateTime.now();
    }
    return Budget(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      month: parsedMonth,
      userId: map['userId'] as String,
    );
  }
}