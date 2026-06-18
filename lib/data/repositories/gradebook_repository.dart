import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/sql_service.dart';

class GradebookRepository {
  final SqlService _sqlService;

  GradebookRepository(this._sqlService);

  Future<List<Map<String, dynamic>>> getClassesForTeacher(String teacherId) async {
    final response = await http.get(Uri.parse('${_sqlService.windowsUrl}/api/teacher/$teacherId/classes'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return List<Map<String, dynamic>>.from(data['classes']);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getCoursesForTeacherAndClass(String teacherId, String classId) async {
    final response = await http.get(Uri.parse('${_sqlService.windowsUrl}/api/teacher/$teacherId/courses/$classId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return List<Map<String, dynamic>>.from(data['courses']);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getStudentsInClass(String classId) async {
    final response = await http.get(Uri.parse('${_sqlService.windowsUrl}/api/classes/$classId/students'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return List<Map<String, dynamic>>.from(data['students']);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getGrades(String classId, String courseId, String term, int year) async {
    final response = await http.get(Uri.parse(
        '${_sqlService.windowsUrl}/api/gradebook?classId=$classId&courseId=$courseId&term=$term&year=$year'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return List<Map<String, dynamic>>.from(data['grades']);
      }
    }
    return [];
  }

  Future<bool> saveGrades(String term, int year, String courseId, List<Map<String, dynamic>> grades) async {
    final response = await http.post(
      Uri.parse('${_sqlService.windowsUrl}/api/gradebook'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'term': term,
        'year': year,
        'courseId': courseId,
        'grades': grades,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }
    return false;
  }
}
