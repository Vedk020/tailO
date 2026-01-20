import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<UserEntity> login(String email, String password) async {
    // In real app, this calls API. Here we use our Service.
    await _authService.login(email, password);
    return UserEntity(
      id: '1',
      name: _authService.userName,
      email: _authService.userEmail,
      imageUrl: _authService.userImage,
    );
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (!_authService.isLoggedIn) return null;
    return UserEntity(
      id: '1',
      name: _authService.userName,
      email: _authService.userEmail,
      imageUrl: _authService.userImage,
    );
  }
}
