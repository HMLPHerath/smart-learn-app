import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<void> login({required String email, required String password}) async {
    await _authService.login(email: email, password: password);
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> forgotPassword(String email) async {
    await _authService.forgotPassword(email);
  }

  User? get currentUser => _authService.currentUser;
}
