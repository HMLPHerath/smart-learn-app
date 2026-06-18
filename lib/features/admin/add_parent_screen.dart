import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../di/injection.dart';

class AddParentScreen extends StatefulWidget {
  const AddParentScreen({super.key});

  @override
  State<AddParentScreen> createState() => _AddParentScreenState();
}

class _AddParentScreenState extends State<AddParentScreen> {
  final _parentIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController(); // Not mapped in backend currently, but in UI

  // Student Link Information
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _relationshipController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _parentIdController.dispose();
    _fullNameController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _studentIdController.dispose();
    _studentNameController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _submitParent() async {
    if (_parentIdController.text.isEmpty || _fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parent ID and Full Name are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await parentRepository.addParent({
      'parentId': _parentIdController.text.trim(),
      'fullName': _fullNameController.text.trim(),
      'nic': _nicController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
    });

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parent added successfully! Default password is 123456.')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add parent. Please try again.')),
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
                              'Add Parent',
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
                            'Create parent record and link student',
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
                        const _ParentPhotoCard(),
                        const SizedBox(height: 18),
                        _ParentFormCard(
                          parentIdController: _parentIdController,
                          fullNameController: _fullNameController,
                          nicController: _nicController,
                          phoneController: _phoneController,
                          emailController: _emailController,
                          addressController: _addressController,
                          studentIdController: _studentIdController,
                          studentNameController: _studentNameController,
                          relationshipController: _relationshipController,
                        ),
                        const SizedBox(height: 18),
                        AppButton(
                          text: 'Save Parent',
                          onTap: _submitParent,
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

class _ParentPhotoCard extends StatelessWidget {
  const _ParentPhotoCard();

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
            'Upload Parent Photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap here to add parent profile image',
            style: TextStyle(fontSize: 13, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _ParentFormCard extends StatelessWidget {
  final TextEditingController parentIdController;
  final TextEditingController fullNameController;
  final TextEditingController nicController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController studentIdController;
  final TextEditingController studentNameController;
  final TextEditingController relationshipController;

  const _ParentFormCard({
    required this.parentIdController,
    required this.fullNameController,
    required this.nicController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.studentIdController,
    required this.studentNameController,
    required this.relationshipController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _box(),
      child: Column(
        children: [
          const _SectionLabel(title: 'Parent Information'),
          const SizedBox(height: 14),
          AppTextField(
            controller: parentIdController,
            label: 'Parent ID',
            hintText: 'PAR-2026-0002',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: fullNameController,
            label: 'Full Name',
            hintText: 'Enter parent full name',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: nicController,
            label: 'NIC Number',
            hintText: 'Enter NIC number',
            keyboardType: TextInputType.text,
          ),
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
            hintText: 'parent@gmail.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: addressController,
            label: 'Address',
            hintText: 'Enter home address',
            maxLines: 3,
            keyboardType: TextInputType.multiline,
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
