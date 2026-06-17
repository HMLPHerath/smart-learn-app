import '../core/services/sql_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/student_repository.dart';
import '../data/repositories/teacher_repository.dart';
import '../data/repositories/parent_repository.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/notice_repository.dart';

final sqlService = SqlService();

final authRepository = AuthRepository(sqlService);
final userRepository = UserRepository(sqlService);
final studentRepository = StudentRepository(sqlService);
final teacherRepository = TeacherRepository(sqlService);
final parentRepository = ParentRepository(sqlService);
final contentRepository = ContentRepository(sqlService);
final noticeRepository = NoticeRepository(sqlService);
