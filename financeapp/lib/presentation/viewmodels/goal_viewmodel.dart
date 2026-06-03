import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/goal_entity.dart';

final goalsProvider = StreamProvider.family<List<GoalEntity>, String>((ref, userId) {
  final firestore = getIt<FirebaseFirestore>();
  return firestore
      .collection('goals')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final d = doc.data();
            return GoalEntity(
              id: doc.id,
              userId: d['userId'],
              title: d['title'],
              targetAmount: (d['targetAmount'] as num).toDouble(),
              currentAmount: (d['currentAmount'] as num).toDouble(),
              deadline: DateTime.fromMillisecondsSinceEpoch(d['deadline']),
              emoji: d['emoji'] ?? '🎯',
            );
          }).toList());
});

class GoalNotifier extends StateNotifier<AsyncValue<void>> {
  GoalNotifier() : super(const AsyncValue.data(null));

  final _firestore = getIt<FirebaseFirestore>();

  Future<bool> addGoal({
    required String userId,
    required String title,
    required double targetAmount,
    required DateTime deadline,
    required String emoji,
  }) async {
    try {
      state = const AsyncValue.loading();
      final id = const Uuid().v4();
      await _firestore.collection('goals').doc(id).set({
        'userId': userId,
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': 0.0,
        'deadline': deadline.millisecondsSinceEpoch,
        'emoji': emoji,
      });
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> addToGoal(String goalId, double amount) async {
    try {
      await _firestore.collection('goals').doc(goalId).update({
        'currentAmount': FieldValue.increment(amount),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    try {
      await _firestore.collection('goals').doc(goalId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final goalNotifierProvider =
    StateNotifierProvider<GoalNotifier, AsyncValue<void>>((ref) => GoalNotifier());