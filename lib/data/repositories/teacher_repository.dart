import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/sql_service.dart';
import '../models/teacher_model.dart';

class TeacherRepository {
  final SqlService sqlService;
  TeacherRepository(this.sqlService);

  Future<List<TeacherModel>> getTeachers() async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/teachers');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['teachers'] != null) {
          final List<dynamic> list = data['teachers'];
          return list.map((item) => TeacherModel.fromMap(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching teachers: $e");
      return [];
    }
  }

  Future<TeacherModel?> getTeacherById(String id) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/teachers/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['teacher'] != null) {
          return TeacherModel.fromMap(data['teacher']);
        }
      }
      return null;
    } catch (e) {
      print("Error fetching teacher by ID: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTeacherProfile(String teacherId) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/teacher/$teacherId/profile');
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
      print("Error fetching teacher profile: $e");
      return null;
    }
  }

  Future<bool> addTeacher(Map<String, dynamic> teacherData) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/teachers');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(teacherData),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("Error adding teacher: $e");
      return false;
    }
  }
  Future<List<Map<String, dynamic>>> getStudentsForTeacher(String teacherId) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/teacher/$teacherId/students');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['students'] != null) {
          return List<Map<String, dynamic>>.from(data['students']);
        }
      }
      return [];
    } catch (e) {
      print("Error fetching students for teacher: $e");
      return [];
    }
  }
}
