// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_database.dart';

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  TransactionDao? _transactionDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);
        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `transactions` (`id` TEXT NOT NULL, `userId` TEXT NOT NULL, `title` TEXT NOT NULL, `amount` REAL NOT NULL, `dateMillis` INTEGER NOT NULL, `type` TEXT NOT NULL, `category` TEXT NOT NULL, `description` TEXT, `syncedToCloud` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  TransactionDao get transactionDao {
    return _transactionDaoInstance ??=
        _$TransactionDao(database, changeListener);
  }
}

class _$TransactionDao extends TransactionDao {
  _$TransactionDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _transactionModelInsertionAdapter = InsertionAdapter(
            database,
            'transactions',
            (TransactionModel item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'title': item.title,
                  'amount': item.amount,
                  'dateMillis': item.dateMillis,
                  'type': item.type,
                  'category': item.category,
                  'description': item.description,
                  'syncedToCloud': item.syncedToCloud
                },
            changeListener),
        _transactionModelUpdateAdapter = UpdateAdapter(
            database,
            'transactions',
            ['id'],
            (TransactionModel item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'title': item.title,
                  'amount': item.amount,
                  'dateMillis': item.dateMillis,
                  'type': item.type,
                  'category': item.category,
                  'description': item.description,
                  'syncedToCloud': item.syncedToCloud
                },
            changeListener);

  final sqflite.DatabaseExecutor database;
  final StreamController<String> changeListener;
  final QueryAdapter _queryAdapter;
  final InsertionAdapter<TransactionModel> _transactionModelInsertionAdapter;
  final UpdateAdapter<TransactionModel> _transactionModelUpdateAdapter;

  @override
  Future<List<TransactionModel>> getTransactionsByUser(String userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM transactions WHERE userId = ?1 ORDER BY dateMillis DESC',
        mapper: (Map<String, Object?> row) => TransactionModel(
              id: row['id'] as String,
              userId: row['userId'] as String,
              title: row['title'] as String,
              amount: row['amount'] as double,
              dateMillis: row['dateMillis'] as int,
              type: row['type'] as String,
              category: row['category'] as String,
              description: row['description'] as String?,
              syncedToCloud: row['syncedToCloud'] as int,
            ),
        arguments: [userId]);
  }

  @override
  Stream<List<TransactionModel>> watchTransactionsByUser(String userId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM transactions WHERE userId = ?1 ORDER BY dateMillis DESC',
        mapper: (Map<String, Object?> row) => TransactionModel(
              id: row['id'] as String,
              userId: row['userId'] as String,
              title: row['title'] as String,
              amount: row['amount'] as double,
              dateMillis: row['dateMillis'] as int,
              type: row['type'] as String,
              category: row['category'] as String,
              description: row['description'] as String?,
              syncedToCloud: row['syncedToCloud'] as int,
            ),
        queryableName: 'transactions',
        isView: false,
        arguments: [userId]);
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
      String userId, int start, int end) async {
    return _queryAdapter.queryList(
        'SELECT * FROM transactions WHERE userId = ?1 AND dateMillis >= ?2 AND dateMillis <= ?3 ORDER BY dateMillis DESC',
        mapper: (Map<String, Object?> row) => TransactionModel(
              id: row['id'] as String,
              userId: row['userId'] as String,
              title: row['title'] as String,
              amount: row['amount'] as double,
              dateMillis: row['dateMillis'] as int,
              type: row['type'] as String,
              category: row['category'] as String,
              description: row['description'] as String?,
              syncedToCloud: row['syncedToCloud'] as int,
            ),
        arguments: [userId, start, end]);
  }

  @override
  Future<void> insertTransaction(TransactionModel transaction) async {
    await _transactionModelInsertionAdapter.insertOnConflictUpdate(transaction);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionModelUpdateAdapter.update(
        transaction, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM transactions WHERE id = ?1',
        arguments: [id]);
  }
}
