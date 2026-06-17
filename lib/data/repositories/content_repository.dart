import '../../core/services/sql_service.dart';
import '../models/course_model.dart';
import '../models/notice_model.dart';
import '../models/schedule_model.dart';

class ContentRepository {
  final SqlService sqlService;

  ContentRepository(this.sqlService);

  Future<List<CourseModel>> getCourses() async {
    return [];
  }

  Future<List<ScheduleModel>> getSchedules() async {
    return [];
  }

  Future<List<NoticeModel>> getNotices() async {
    return [];
  }

  Stream<List<Map<String, dynamic>>> shortNotes() => const Stream.empty();
  Stream<List<Map<String, dynamic>>> guideBooks() => const Stream.empty();
  Stream<List<Map<String, dynamic>>> courses() => const Stream.empty();
  Stream<List<Map<String, dynamic>>> results() => const Stream.empty();
  Stream<List<Map<String, dynamic>>> notices() => const Stream.empty();
}

