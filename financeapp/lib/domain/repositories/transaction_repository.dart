import 'package:dartz/dartz.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<String, List<TransactionEntity>>> getTransactions(String userId);
  Future<Either<String, TransactionEntity>> addTransaction(TransactionEntity transaction);
  Future<Either<String, TransactionEntity>> updateTransaction(TransactionEntity transaction);
  Future<Either<String, bool>> deleteTransaction(String id);
  Future<Either<String, List<TransactionEntity>>> getTransactionsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  );
  Stream<List<TransactionEntity>> watchTransactions(String userId);
}
