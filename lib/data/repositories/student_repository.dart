import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/sql_service.dart';
import '../models/student_model.dart';

class StudentRepository {
  final SqlService sqlService;
  StudentRepository(this.sqlService);

  Future<List<StudentModel>> getStudents() async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/students');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['students'] != null) {
          final List<dynamic> list = data['students'];
          return list.map((item) => StudentModel.fromMap(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching students: $e");
      return [];
    }
  }
  
  Future<StudentModel?> getStudentById(String id) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/students/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['student'] != null) {
          return StudentModel.fromMap(data['student']);
        }
      }
      return null;
    } catch (e) {
      print("Error fetching student by ID: $e");
      return null;
    }
  }
}
