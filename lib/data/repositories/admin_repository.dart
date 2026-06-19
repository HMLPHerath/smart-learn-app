import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/sql_service.dart';
import '../models/schedule_form_models.dart';

class AdminDashboardStats {
  final int totalStudents;
  final int totalParents;
  final int totalTeachers;
  final int totalNotices;
  final List<dynamic> recentAlerts;
  final List<dynamic> latestUpdates;

  AdminDashboardStats({
    required this.totalStudents,
    required this.totalParents,
    required this.totalTeachers,
    required this.totalNotices,
    required this.recentAlerts,
    required this.latestUpdates,
  });

  factory AdminDashboardStats.fromMap(Map<String, dynamic> map) {
    final counts = map['counts'] ?? {};
    return AdminDashboardStats(
      totalStudents: counts['totalStudents'] != null ? int.tryParse(counts['totalStudents'].toString()) ?? 0 : 0,
      totalParents: counts['totalParents'] != null ? int.tryParse(counts['totalParents'].toString()) ?? 0 : 0,
      totalTeachers: counts['totalTeachers'] != null ? int.tryParse(counts['totalTeachers'].toString()) ?? 0 : 0,
      totalNotices: counts['totalNotices'] != null ? int.tryParse(counts['totalNotices'].toString()) ?? 0 : 0,
      recentAlerts: map['recentAlerts'] ?? [],
      latestUpdates: map['latestUpdates'] ?? [],
    );
  }
}

class AdminRepository {
  final SqlService sqlService;
  AdminRepository(this.sqlService);

  Future<AdminDashboardStats?> getDashboardStats() async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/admin/dashboard-stats');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['stats'] != null) {
          return AdminDashboardStats.fromMap(data['stats']);
        }
      }
      return null;
    } catch (e) {
      print("Error fetching admin stats: $e");
      return null;
    }
  }

  Future<List<DropdownClassModel>> getClasses() async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/classes');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['classes'] as List).map((c) => DropdownClassModel.fromMap(c)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching classes: $e");
      return [];
    }
  }

  Future<List<DropdownTeacherModel>> getTeachers() async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/teachers');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['teachers'] as List).map((t) => DropdownTeacherModel.fromMap(t)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching teachers: $e");
      return [];
    }
  }

  Future<List<DropdownCourseModel>> getCourses() async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/courses');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['courses'] as List).map((c) => DropdownCourseModel.fromMap(c)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching courses: $e");
      return [];
    }
  }

  Future<bool> addCourseSchedule({
    required String classId,
    required String courseId,
    required String teacherId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    required String roomIdentifier,
  }) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/schedule');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'classId': classId,
          'courseId': courseId,
          'teacherId': teacherId,
          'dayOfWeek': dayOfWeek,
          'startTime': startTime,
          'endTime': endTime,
          'roomIdentifier': roomIdentifier,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("Error saving schedule: $e");
      return false;
    }
  }
}
