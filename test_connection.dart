import 'package:flutter/material.dart';
import 'lib/core/services/sql_service.dart';
import 'lib/data/repositories/auth_repository.dart';
import 'lib/data/repositories/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = SqlService();
  final authRepo = AuthRepository(service);
  final userRepo = UserRepository(service);
  
  try {
    print("Attempting to login with demo admin...");
    await authRepo.login(email: 'admin@smartedu.com', password: 'demo_hash_here');
    
    final authUser = authRepo.currentUser;
    if (authUser != null) {
      print("Login API successful! UserID: ${authUser.uid}");
      
      print("Fetching user profile...");
      final profile = await userRepo.getUserByUid(authUser.uid);
      if (profile != null) {
        print("Profile fetched successfully!");
        print("Name: ${profile.name}");
        print("Role: ${profile.role}");
        print("Email: ${profile.email}");
      } else {
        print("Failed to fetch profile");
      }
    }
  } catch (e) {
    print("Flow failed: $e");
  }
}


