import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  salary,
  food,
  transport,
  health,
  entertainment,
  education,
  housing,
  investment,
  other,
}

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;
  final String? description;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.description,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  TransactionEntity copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    TransactionCategory? category,
    String? description,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, amount, date, type, category, description];
}
