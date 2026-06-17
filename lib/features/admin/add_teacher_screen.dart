import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../di/injection.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _teacherIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _teacherIdController.dispose();
    _fullNameController.dispose();
    _subjectController.dispose();
    _qualificationsController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitTeacher() async {
    if (_teacherIdController.text.isEmpty || _fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher ID and Full Name are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await teacherRepository.addTeacher({
      'teacherId': _teacherIdController.text.trim(),
      'fullName': _fullNameController.text.trim(),
      'subject': _subjectController.text.trim(),
      'qualifications': _qualificationsController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
    });

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher added successfully! Default password is 123456.')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add teacher. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SafeArea(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
              : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                children: [
                  TopBlueHeader(
                    height: 235,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => context.pop(),
                            ),
                            const Text(
                              'Add Teacher',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 48, top: 6),
                          child: Text(
                            'Create a new teacher profile',
                            style: TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const _TeacherPhotoCard(),
                        const SizedBox(height: 18),
                        _TeacherFormCard(
                          teacherIdController: _teacherIdController,
                          fullNameController: _fullNameController,
                          subjectController: _subjectController,
                          qualificationsController: _qualificationsController,
                          phoneController: _phoneController,
                          emailController: _emailController,
                        ),
                        const SizedBox(height: 18),
                        AppButton(
                          text: 'Save Teacher',
                          onTap: _submitTeacher,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeacherPhotoCard extends StatelessWidget {
  const _TeacherPhotoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _box(),
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: const Color(0xFFD7DDF4),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderBlue, width: 1.2),
            ),
            child: const Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primaryBlue,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Upload Teacher Photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap here to add profile image',
            style: TextStyle(fontSize: 13, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _TeacherFormCard extends StatelessWidget {
  final TextEditingController teacherIdController;
  final TextEditingController fullNameController;
  final TextEditingController subjectController;
  final TextEditingController qualificationsController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  const _TeacherFormCard({
    required this.teacherIdController,
    required this.fullNameController,
    required this.subjectController,
    required this.qualificationsController,
    required this.phoneController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _box(),
      child: Column(
        children: [
          const _SectionLabel(title: 'Teacher Information'),
          const SizedBox(height: 14),
          AppTextField(
            controller: teacherIdController,
            label: 'Teacher ID',
            hintText: 'TEA-2026-0002',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: fullNameController,
            label: 'Full Name',
            hintText: 'Enter teacher full name',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: subjectController,
            label: 'Subject',
            hintText: 'e.g. Mathematics',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: qualificationsController,
            label: 'Qualifications',
            hintText: 'BSc. in Mathematics, PGDE',
            maxLines: 2,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 18),
          const _SectionLabel(title: 'Contact Information'),
          const SizedBox(height: 14),
          AppTextField(
            controller: phoneController,
            label: 'Phone Number',
            hintText: '+94 77 123 4567',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: emailController,
            label: 'Email',
            hintText: 'teacher@gmail.com',
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }
}

BoxDecoration _box() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.borderBlue, width: 1.2),
    boxShadow: const [
      BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4)),
    ],
  );
}
