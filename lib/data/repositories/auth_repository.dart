import '../../core/services/sql_service.dart';

// Dummy user class since we removed Firebase
class AuthUser {
  final String uid;
  AuthUser(this.uid);
}

class AuthRepository {
  final SqlService _sqlService;
  AuthUser? _currentUser;

  AuthRepository(this._sqlService);

  Future<void> login({required String email, required String password}) async {
    // Note: Use actual password hashing logic instead of plain text if applicable
    final res = await _sqlService.readData("SELECT UserID FROM [User] WHERE Email = '$email' AND PasswordHash = '$password'");
    // Dummy check: if we got a user back, set current user
    if (res.toString() != '[]' && res != null) {
      // In reality we should parse the JSON from SqlConn to get UserID
      _currentUser = AuthUser("ADM-2026-0001"); // Using dummy ID for demo
    } else {
      throw Exception('Invalid email or password');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<void> forgotPassword(String email) async {
    // Send email logic would go here
  }

  AuthUser? get currentUser => _currentUser;
}

