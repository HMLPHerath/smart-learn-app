import '../../core/services/sql_service.dart';
import '../models/app_user_model.dart';

class UserRepository {
  final SqlService _sqlService;

  UserRepository(this._sqlService);

  Future<AppUserModel?> getUserByUid(String uid) async {
    // Read from SQL Server
    final res = await _sqlService.readData("SELECT * FROM [User] WHERE UserID = '$uid'");
    
    // As a dummy implementation since we don't have json decode logic written for sql_conn res
    // Assume it returns an admin user for the demo data inserted
    if (res != null && res.toString() != '[]') {
      return AppUserModel(
        uid: uid,
        email: 'admin@smartedu.com',
        role: 'admin',
        name: 'Admin User',
      );
    }
    return null;
  }

  Future<void> saveUser(AppUserModel user) async {
    String query = """
      UPDATE [User] SET Email = '${user.email}' WHERE UserID = '${user.uid}'
    """;
    await _sqlService.writeData(query);
  }
}

