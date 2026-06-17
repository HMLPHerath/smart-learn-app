import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/sql_service.dart';
import '../models/course_model.dart';
import '../models/notice_model.dart';
import '../models/schedule_model.dart';

class ContentRepository {
  final SqlService sqlService;

  ContentRepository(this.sqlService);

  Future<List<CourseModel>> getCourses() async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/courses');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['courses'] != null) {
          final List<dynamic> list = data['courses'];
          return list.map((item) => CourseModel.fromMap(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching courses: $e");
      return [];
    }
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

