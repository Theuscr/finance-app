import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

// Watch transactions as stream
final transactionsProvider = StreamProvider.family<List<TransactionEntity>, String>((ref, userId) {
  return getIt<TransactionRepository>().watchTransactions(userId);
});

// Computed: balance
final balanceProvider = Provider.family<double, String>((ref, userId) {
  final transactions = ref.watch(transactionsProvider(userId));
  return transactions.when(
    data: (list) => list.fold(0.0, (sum, t) => t.isIncome ? sum + t.amount : sum - t.amount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Computed: total income
final totalIncomeProvider = Provider.family<double, String>((ref, userId) {
  final transactions = ref.watch(transactionsProvider(userId));
  return transactions.when(
    data: (list) => list.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Computed: total expense
final totalExpenseProvider = Provider.family<double, String>((ref, userId) {
  final transactions = ref.watch(transactionsProvider(userId));
  return transactions.when(
    data: (list) => list.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Filter provider
final transactionFilterProvider = StateProvider<TransactionType?>((ref) => null);

// Filtered transactions
final filteredTransactionsProvider = Provider.family<List<TransactionEntity>, String>((ref, userId) {
  final filter = ref.watch(transactionFilterProvider);
  final transactions = ref.watch(transactionsProvider(userId));
  return transactions.when(
    data: (list) => filter == null ? list : list.where((t) => t.type == filter).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Transaction actions
class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  final TransactionRepository _repo;

  TransactionNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<bool> addTransaction({
    required String userId,
    required String title,
    required double amount,
    required DateTime date,
    required TransactionType type,
    required TransactionCategory category,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    final transaction = TransactionEntity(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      amount: amount,
      date: date,
      type: type,
      category: category,
      description: description,
    );
    final result = await _repo.addTransaction(transaction);
    return result.fold(
      (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> updateTransaction(TransactionEntity transaction) async {
    state = const AsyncValue.loading();
    final result = await _repo.updateTransaction(transaction);
    return result.fold(
      (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> deleteTransaction(String id) async {
    state = const AsyncValue.loading();
    final result = await _repo.deleteTransaction(id);
    return result.fold(
      (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, AsyncValue<void>>((ref) {
  return TransactionNotifier(getIt<TransactionRepository>());
});
