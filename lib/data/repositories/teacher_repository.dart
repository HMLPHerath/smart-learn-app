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
}
