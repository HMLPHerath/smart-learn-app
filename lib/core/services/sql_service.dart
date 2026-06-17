import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SqlService {
  final String baseUrl = 'http://10.0.2.2:3000'; // For Android emulator. Use localhost or IP for windows/real device.
  // Actually, let's use localhost since they might be running as Windows app
  // Wait, if it's windows it's localhost. Let's make it configurable or fallback.
  final String windowsUrl = 'http://localhost:3000';
  
  bool _isConnected = false;

  Future<void> connect() async {
    if (_isConnected) return;
    try {
      final response = await http.get(Uri.parse('$windowsUrl/test'));
      if (response.statusCode == 200) {
        _isConnected = true;
        debugPrint("Connected to API: ${response.body}");
      } else {
        throw Exception("Failed to connect: ${response.body}");
      }
    } catch (e) {
      debugPrint("API Connection Error: $e");
      rethrow;
    }
  }

  Future<void> insertDemoData() async {
    try {
      final response = await http.post(Uri.parse('$windowsUrl/demo-insert'));
      debugPrint("Demo Insert Response: ${response.body}");
    } catch (e) {
      debugPrint("Demo Insert Error: $e");
    }
  }

  // Generic methods
  Future<List<dynamic>> readData(String query) async {
    return [];
  }

  Future<void> writeData(String query) async {
  }
}
