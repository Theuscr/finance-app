import 'package:dartz/dartz.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryFirebaseOnly implements TransactionRepository {
  final FirebaseDataSource _remote;

  TransactionRepositoryFirebaseOnly(this._remote);

  @override
  Future<Either<String, List<TransactionEntity>>> getTransactions(String userId) async {
    try {
      final list = await _remote.getTransactions(userId);
      return Right(list.map((t) => t.toEntity()).toList());
    } catch (e) {
      return Left('Erro ao carregar transações: $e');
    }
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions(String userId) {
    return _remote.watchTransactions(userId)
        .map((list) => list.map((t) => t.toEntity()).toList());
  }

  @override
  Future<Either<String, TransactionEntity>> addTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _remote.addTransaction(model);
      return Right(transaction);
    } catch (e) {
      return Left('Erro ao adicionar transação: $e');
    }
  }

  @override
  Future<Either<String, TransactionEntity>> updateTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _remote.updateTransaction(model);
      return Right(transaction);
    } catch (e) {
      return Left('Erro ao atualizar transação: $e');
    }
  }

  @override
  Future<Either<String, bool>> deleteTransaction(String id) async {
    try {
      await _remote.deleteTransaction(id);
      return const Right(true);
    } catch (e) {
      return Left('Erro ao remover transação: $e');
    }
  }

  @override
  Future<Either<String, List<TransactionEntity>>> getTransactionsByDateRange(
    String userId, DateTime start, DateTime end) async {
    try {
      final list = await _remote.getTransactions(userId);
      final filtered = list.where((t) =>
        t.dateMillis >= start.millisecondsSinceEpoch &&
        t.dateMillis <= end.millisecondsSinceEpoch).toList();
      return Right(filtered.map((t) => t.toEntity()).toList());
    } catch (e) {
      return Left('Erro ao filtrar: $e');
    }
  }
}