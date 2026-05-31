import 'package:floor/floor.dart';
import '../../domain/entities/transaction_entity.dart';

@Entity(tableName: 'transactions')
class TransactionModel {
  @PrimaryKey()
  final String id;

  final String userId;
  final String title;
  final double amount;
  final int dateMillis;
  final String type; // 'income' | 'expense'
  final String category;
  final String? description;
  final int syncedToCloud; // 0 = false, 1 = true

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.dateMillis,
    required this.type,
    required this.category,
    this.description,
    this.syncedToCloud = 0,
  });

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      amount: entity.amount,
      dateMillis: entity.date.millisecondsSinceEpoch,
      type: entity.type.name,
      category: entity.category.name,
      description: entity.description,
      syncedToCloud: 1,
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      title: title,
      amount: amount,
      date: DateTime.fromMillisecondsSinceEpoch(dateMillis),
      type: TransactionType.values.firstWhere((e) => e.name == type),
      category: TransactionCategory.values.firstWhere((e) => e.name == category),
      description: description,
    );
  }
}
