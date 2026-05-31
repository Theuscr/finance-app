import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// Provider for auth state (stream)
final authViewModelProvider = StreamProvider<UserEntity?>((ref) {
  final repo = getIt<AuthRepository>();
  return repo.watchAuthState();
});

// Provider for current user
final currentUserProvider = Provider<UserEntity?>((ref) {
  return getIt<AuthRepository>().currentUser;
});

// Auth actions notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repo.login(email, password);
    return result.fold(
      (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncValue.data(user);
        return true;
      },
    );
  }

  Future<bool> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repo.register(name, email, password);
    return result.fold(
      (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncValue.data(user);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }

  String? get errorMessage {
    return state.whenOrNull(error: (err, _) => err.toString());
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(getIt<AuthRepository>());
});
