import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../models/transaction_model.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDao _localDao;
  final FirebaseDataSource _remote;

  TransactionRepositoryImpl(this._localDao, this._remote);

  @override
  Future<Either<String, List<TransactionEntity>>> getTransactions(String userId) async {
    try {
      // Try remote first, fallback to local
      try {
        final remoteList = await _remote.getTransactions(userId);
        // Sync to local
        for (final t in remoteList) {
          await _localDao.insertTransaction(t);
        }
        return Right(remoteList.map((t) => t.toEntity()).toList());
      } catch (_) {
        final localList = await _localDao.getTransactionsByUser(userId);
        return Right(localList.map((t) => t.toEntity()).toList());
      }
    } catch (e) {
      return Left('Erro ao carregar transações: ${e.toString()}');
    }
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions(String userId) {
    try {
      return _remote
          .watchTransactions(userId)
          .map((list) => list.map((t) => t.toEntity()).toList());
    } catch (_) {
      return _localDao
          .watchTransactionsByUser(userId)
          .map((list) => list.map((t) => t.toEntity()).toList());
    }
  }

  @override
  Future<Either<String, TransactionEntity>> addTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _localDao.insertTransaction(model);
      try {
        await _remote.addTransaction(model);
      } catch (_) {
        // Saved locally, will sync later
      }
      return Right(transaction);
    } catch (e) {
      return Left('Erro ao adicionar transação: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, TransactionEntity>> updateTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _localDao.updateTransaction(model);
      try {
        await _remote.updateTransaction(model);
      } catch (_) {}
      return Right(transaction);
    } catch (e) {
      return Left('Erro ao atualizar transação: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> deleteTransaction(String id) async {
    try {
      await _localDao.deleteTransaction(id);
      try {
        await _remote.deleteTransaction(id);
      } catch (_) {}
      return const Right(true);
    } catch (e) {
      return Left('Erro ao remover transação: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<TransactionEntity>>> getTransactionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final list = await _localDao.getTransactionsByDateRange(
        userId,
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      );
      return Right(list.map((t) => t.toEntity()).toList());
    } catch (e) {
      return Left('Erro ao filtrar transações: ${e.toString()}');
    }
  }
}
