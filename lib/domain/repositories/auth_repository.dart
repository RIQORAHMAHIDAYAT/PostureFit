import '../entities/user_entity.dart';

/// Abstract interface untuk AuthRepository.
/// Implementasi konkrit ada di data/repositories/auth_repository_impl.dart
abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  });
  Future<UserEntity> signInWithGoogle();
  Future<void> logout();
}
