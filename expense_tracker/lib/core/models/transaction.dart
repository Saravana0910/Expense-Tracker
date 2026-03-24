import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final String paymentMethod;
  final String userId;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    required this.paymentMethod,
    required this.userId,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.parse(map['date'].toString()),
      notes: map['notes'] as String?,
      paymentMethod: map['paymentMethod'] as String,
      userId: map['userId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toUtc(),
      'notes': notes,
      'paymentMethod': paymentMethod,
      'userId': userId,
    };
  }

  Transaction copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
    String? paymentMethod,
    String? userId,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      userId: userId ?? this.userId,
    );
  }
}