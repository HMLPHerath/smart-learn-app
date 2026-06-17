import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/services/sql_service.dart';

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
      totalStudents: counts['totalStudents'] ?? 0,
      totalParents: counts['totalParents'] ?? 0,
      totalTeachers: counts['totalTeachers'] ?? 0,
      totalNotices: counts['totalNotices'] ?? 0,
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
}
