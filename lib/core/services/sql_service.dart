import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SqlService {
  String get windowsUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      // Emulator එකට 10.0.2.2 භාවිතා කළ යුතුයි
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
    // Vercel Live Backend URL
    // return 'https://backend-1-dusky.vercel.app';
  }

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
