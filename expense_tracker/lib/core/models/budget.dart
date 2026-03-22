import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 2)
class Budget extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime month;

  @HiveField(3)
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
}