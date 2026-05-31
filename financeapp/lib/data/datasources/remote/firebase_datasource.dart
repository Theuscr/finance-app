import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';

@lazySingleton
class FirebaseDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseDataSource(this._auth, this._firestore);

  // ──────── AUTH ────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  // ──────── USER ────────
  Future<void> saveUser(UserModel user) {
    return _firestore.collection('users').doc(user.id).set(user.toFirestore());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  // ──────── TRANSACTIONS ────────
  Future<List<TransactionModel>> getTransactions(String userId) async {
    final query = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('dateMillis', descending: true)
        .get();
    return query.docs.map((doc) {
      final data = doc.data();
      return TransactionModel(
        id: doc.id,
        userId: data['userId'],
        title: data['title'],
        amount: (data['amount'] as num).toDouble(),
        dateMillis: data['dateMillis'],
        type: data['type'],
        category: data['category'],
        description: data['description'],
        syncedToCloud: 1,
      );
    }).toList();
  }

  Stream<List<TransactionModel>> watchTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('dateMillis', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return TransactionModel(
                id: doc.id,
                userId: data['userId'],
                title: data['title'],
                amount: (data['amount'] as num).toDouble(),
                dateMillis: data['dateMillis'],
                type: data['type'],
                category: data['category'],
                description: data['description'],
                syncedToCloud: 1,
              );
            }).toList());
  }

  Future<void> addTransaction(TransactionModel t) {
    return _firestore.collection('transactions').doc(t.id).set({
      'userId': t.userId,
      'title': t.title,
      'amount': t.amount,
      'dateMillis': t.dateMillis,
      'type': t.type,
      'category': t.category,
      'description': t.description,
    });
  }

  Future<void> updateTransaction(TransactionModel t) {
    return _firestore.collection('transactions').doc(t.id).update({
      'title': t.title,
      'amount': t.amount,
      'dateMillis': t.dateMillis,
      'type': t.type,
      'category': t.category,
      'description': t.description,
    });
  }

  Future<void> deleteTransaction(String id) {
    return _firestore.collection('transactions').doc(id).delete();
  }
}
