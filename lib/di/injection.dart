import '../core/services/sql_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';

final sqlService = SqlService();

final authRepository = AuthRepository(sqlService);
final userRepository = UserRepository(sqlService);
