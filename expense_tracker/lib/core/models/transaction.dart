import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final String paymentMethod;

  @HiveField(6)
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