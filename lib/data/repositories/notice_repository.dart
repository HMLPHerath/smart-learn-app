import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/sql_service.dart';
import '../models/notice_model.dart';

class NoticeRepository {
  final SqlService sqlService;
  NoticeRepository(this.sqlService);

  Future<List<NoticeModel>> getNotices() async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/notices');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['notices'] != null) {
          final List<dynamic> list = data['notices'];
          return list.map((item) => NoticeModel.fromMap(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching notices: $e");
      return [];
    }
  }

  Future<bool> addNotice(Map<String, dynamic> noticeData) async {
    final url = Uri.parse('${sqlService.windowsUrl}/api/notices');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(noticeData),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("Error adding notice: $e");
      return false;
    }
  }
}
