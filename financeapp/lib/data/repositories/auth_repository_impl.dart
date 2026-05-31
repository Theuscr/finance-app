import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseDataSource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Future<Either<String, UserEntity>> login(String email, String password) async {
    try {
      final credential = await _remote.signIn(email, password);
      final uid = credential.user!.uid;
      final userModel = await _remote.getUser(uid);
      if (userModel == null) {
        return const Left('Usuário não encontrado.');
      }
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(_parseFirebaseError(e.toString()));
    }
  }

  @override
  Future<Either<String, UserEntity>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final credential = await _remote.register(email, password);
      final uid = credential.user!.uid;
      final model = UserModel(
        id: uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      await _remote.saveUser(model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(_parseFirebaseError(e.toString()));
    }
  }

  @override
  Future<Either<String, bool>> logout() async {
    try {
      await _remote.signOut();
      return const Right(true);
    } catch (e) {
      return Left('Erro ao sair: ${e.toString()}');
    }
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return _remote.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      final model = await _remote.getUser(user.uid);
      return model?.toEntity();
    });
  }

  @override
  UserEntity? get currentUser {
    final user = _remote.currentUser;
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      createdAt: DateTime.now(),
    );
  }

  String _parseFirebaseError(String error) {
    if (error.contains('user-not-found')) return 'E-mail não cadastrado.';
    if (error.contains('wrong-password')) return 'Senha incorreta.';
    if (error.contains('email-already-in-use')) return 'E-mail já cadastrado.';
    if (error.contains('weak-password')) return 'Senha muito fraca (mínimo 6 caracteres).';
    if (error.contains('invalid-email')) return 'E-mail inválido.';
    if (error.contains('network-request-failed')) return 'Sem conexão com a internet.';
    return 'Erro de autenticação. Tente novamente.';
  }
}
