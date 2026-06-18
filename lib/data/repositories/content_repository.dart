import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/sql_service.dart';
import '../models/course_model.dart';
import '../models/notice_model.dart';
import '../models/schedule_model.dart';
import '../models/guide_book_model.dart';

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

  Future<List<CourseModel>> getStudentSchedule(String studentId) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/student/$studentId/schedule');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['schedule'] != null) {
          final List<dynamic> list = data['schedule'];
          return list.map((item) => CourseModel.fromMap(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching student schedule: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getStudentProfile(String studentId) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/student/$studentId/profile');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['profile'] != null) {
          return data['profile'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print("Error fetching student profile: $e");
      return null;
    }
  }

  Future<List<ScheduleModel>> getSchedules() async {
    return [];
  }

  Future<List<NoticeModel>> getNotices() async {
    return [];
  }

  Stream<List<Map<String, dynamic>>> shortNotes() => const Stream.empty();

  Future<List<GuideBookModel>> getGuideBooks() async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/guidebooks');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['guidebooks'] != null) {
          final List<dynamic> list = data['guidebooks'];
          return list.map((item) => GuideBookModel.fromMap(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching guide books: $e");
      return [];
    }
  }

  Future<bool> addGuideBook(GuideBookModel book) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/guidebooks');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(book.toMap()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("Error adding guide book: $e");
      return false;
    }
  }

  Future<String?> uploadFile(List<int> bytes, String filename) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/upload');
    try {
      final request = http.MultipartRequest('POST', url);
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['fileUrl'] != null) {
          return data['fileUrl'];
        }
      }
      return null;
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> courses() => const Stream.empty();
  Stream<List<Map<String, dynamic>>> results() => const Stream.empty();
  Stream<List<Map<String, dynamic>>> notices() => const Stream.empty();
}

