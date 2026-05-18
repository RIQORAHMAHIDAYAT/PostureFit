import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementasi konkrit dari AuthRepository.
/// Di sini nanti akan terhubung ke API/Firebase/local storage.
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    // TODO: Implementasikan koneksi ke API/Firebase
    throw UnimplementedError('login() belum diimplementasikan');
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // TODO: Implementasikan koneksi ke API/Firebase
    throw UnimplementedError('register() belum diimplementasikan');
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    // TODO: Implementasikan Google Sign-In
    throw UnimplementedError('signInWithGoogle() belum diimplementasikan');
  }

  @override
  Future<void> logout() async {
    // TODO: Implementasikan logout
    throw UnimplementedError('logout() belum diimplementasikan');
  }
}
