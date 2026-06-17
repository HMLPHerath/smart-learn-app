import 'package:flutter/material.dart';

import 'app.dart';
import 'di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try connecting to SQL Server on app start
  try {
    await sqlService.connect();
    // Try inserting demo data to check connection
    await sqlService.insertDemoData();
  } catch (e) {
    debugPrint("SQL Connection Error: $e");
  }
  
  runApp(const SmartEduApp());
}
