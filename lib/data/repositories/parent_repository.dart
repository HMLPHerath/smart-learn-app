import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/sql_service.dart';
import '../models/parent_model.dart';

class ParentRepository {
  final SqlService sqlService;
  ParentRepository(this.sqlService);

  Future<List<ParentModel>> getParents() async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/parents');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['parents'] != null) {
          final List<dynamic> list = data['parents'];
          return list.map((item) => ParentModel.fromMap(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching parents: $e");
      return [];
    }
  }

  Future<ParentModel?> getParentById(String id) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/parents/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['parent'] != null) {
          return ParentModel.fromMap(data['parent']);
        }
      }
      return null;
    } catch (e) {
      print("Error fetching parent by ID: $e");
      return null;
    }
  }
}
