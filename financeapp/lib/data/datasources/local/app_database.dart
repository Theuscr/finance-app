import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../../models/transaction_model.dart';

part 'app_database.g.dart';

@dao
abstract class TransactionDao {
  @Query('SELECT * FROM transactions WHERE userId = :userId ORDER BY dateMillis DESC')
  Future<List<TransactionModel>> getTransactionsByUser(String userId);

  @Query('SELECT * FROM transactions WHERE userId = :userId ORDER BY dateMillis DESC')
  Stream<List<TransactionModel>> watchTransactionsByUser(String userId);

  @Query('SELECT * FROM transactions WHERE userId = :userId AND dateMillis >= :start AND dateMillis <= :end ORDER BY dateMillis DESC')
  Future<List<TransactionModel>> getTransactionsByDateRange(String userId, int start, int end);

  @insert
  Future<void> insertTransaction(TransactionModel transaction);

  @update
  Future<void> updateTransaction(TransactionModel transaction);

  @Query('DELETE FROM transactions WHERE id = :id')
  Future<void> deleteTransaction(String id);
}

@Database(version: 1, entities: [TransactionModel])
abstract class AppDatabase extends FloorDatabase {
  TransactionDao get transactionDao;
}
