import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/sql_service.dart';

class AuthUser {
  final String uid;
  AuthUser(this.uid);
}

class AuthRepository {
  final SqlService _sqlService;
  AuthUser? _currentUser;

  AuthRepository(this._sqlService);

  Future<void> login({required String email, required String password}) async {
    final url = Uri.parse('${_sqlService.windowsUrl}/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _currentUser = AuthUser(data['userId']);
        // Store token securely if needed
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
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
