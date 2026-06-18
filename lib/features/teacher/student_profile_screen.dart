import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../data/models/student_model.dart';
import '../../di/injection.dart';

class StudentProfileScreen extends StatefulWidget {
  final String studentId;

  const StudentProfileScreen({super.key, required this.studentId});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _isLoading = true;
  StudentModel? _student;

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    final student = await studentRepository.getStudentById(widget.studentId);
    if (mounted) {
      setState(() {
        _student = student;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'Active') return const Color(0xFFCBE8C7);
    if (status == 'Pending') return const Color(0xFFF5DE9B);
    if (status == 'Suspended') return const Color(0xFFF0C7C7);
    return const Color(0xFFEEEEEE);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    if (_student == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text("Student not found.")),
      );
    }

    final s = _student!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            children: [
              TopBlueHeader(
                height: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Student Profile',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white24,
                          child: s.profilePictureUri != null && s.profilePictureUri!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(36),
                                  child: Image.network(s.profilePictureUri!, fit: BoxFit.cover, width: 72, height: 72),
                                )
                              : const Icon(Icons.person, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      s.studentId,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(s.accountStatus),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      s.accountStatus,
                                      style: const TextStyle(
                                        color: AppColors.textBlack,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    _InfoCard(
                      title: 'Personal Information',
                      children: [
                        _InfoRow(icon: Icons.cake_outlined, label: 'Date of Birth', value: s.dateOfBirth.substring(0, 10)),
                        const Divider(height: 24, color: AppColors.borderSoft),
                        _InfoRow(icon: Icons.location_on_outlined, label: 'Home Address', value: s.homeAddress),
                        const Divider(height: 24, color: AppColors.borderSoft),
                        _InfoRow(icon: Icons.class_outlined, label: 'Class', value: s.classId ?? 'Not Assigned'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _InfoCard(
                      title: 'Contact Information',
                      children: [
                        _InfoRow(icon: Icons.email_outlined, label: 'Email', value: s.email),
                        const Divider(height: 24, color: AppColors.borderSoft),
                        _InfoRow(icon: Icons.phone_outlined, label: 'Phone Number', value: s.phoneNumber),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderBlue, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.mutedText),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
