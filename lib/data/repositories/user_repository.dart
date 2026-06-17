import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/sql_service.dart';
import '../models/app_user_model.dart';

class UserRepository {
  final SqlService _sqlService;

  UserRepository(this._sqlService);

  Future<AppUserModel?> getUserByUid(String uid) async {
    final url = Uri.parse('${_sqlService.windowsUrl}/api/users/$uid');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return AppUserModel.fromMap(data['user']);
        }
      }
      return null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<void> saveUser(AppUserModel user) async {
    // API endpoint for updating a user would go here.
    // For now, this is a placeholder.
  }
}
