import '../core/services/auth_service.dart';
import '../core/services/firestore_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';

final authService = AuthService();
final firestoreService = FirestoreService();

final authRepository = AuthRepository(authService);
final userRepository = UserRepository(firestoreService);
