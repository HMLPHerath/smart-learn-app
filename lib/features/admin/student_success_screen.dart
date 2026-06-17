import 'package:flutter/material.dart';

class StudentSuccessScreen extends StatelessWidget {
  const StudentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Success')),
      body: const Center(child: Text('Student admitted successfully!')),
    );
  }
}
