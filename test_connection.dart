import 'package:flutter/material.dart';
import 'lib/core/services/sql_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = SqlService();
  try {
    print("Attempting to connect to API at ${service.windowsUrl}...");
    await service.connect();
    print("Connection successful.");
    
    print("Attempting to insert demo data...");
    await service.insertDemoData();
  } catch (e) {
    print("Connection failed: $e");
  }
}

