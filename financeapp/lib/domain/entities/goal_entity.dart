import 'package:equatable/equatable.dart';

class GoalEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String emoji;

  const GoalEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.emoji,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;
  bool get isCompleted => currentAmount >= targetAmount;
  double get remaining => (targetAmount - currentAmount).clamp(0, double.infinity);

  GoalEntity copyWith({
    String? id,
    String? userId,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? emoji,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      emoji: emoji ?? this.emoji,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, targetAmount, currentAmount, deadline, emoji];
}