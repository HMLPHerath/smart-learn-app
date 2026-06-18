import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/logout_helper.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/circular_avatar.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../di/injection.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _loading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = authRepository.currentUser?.uid;
      if (uid != null) {
        final profile = await contentRepository.getStudentProfile(uid);
        if (mounted) {
          setState(() {
            _profileData = profile;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not loaded or data missing, use fallbacks or loading state
    final fullName = _profileData?['FullName'] ?? 'Student';
    final studentId = _profileData?['StudentID'] ?? authRepository.currentUser?.uid ?? 'STU-UNKNOWN';
    final className = _profileData?['ClassName'] ?? 'Not Assigned';
    final attendance = _profileData?['Attendance'] ?? 'N/A';
    final parentName = _profileData?['ParentName'] ?? 'Not Assigned';
    final email = _profileData?['Email'] ?? 'Not Available';
    final phone = _profileData?['PhoneNumber'] ?? 'Not Available';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  children: [
                    TopBlueHeader(
                      height: 285,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const CircularAvatar(radius: 48),
                          const SizedBox(height: 14),
                          Text(
                            fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$studentId • $className',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          _ProfileInfoCard(
                            title: 'Full Name',
                            value: fullName,
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 14),
                          _ProfileInfoCard(
                            title: 'Class',
                            value: className,
                            icon: Icons.school_outlined,
                          ),
                          const SizedBox(height: 14),
                          _ProfileInfoCard(
                            title: 'Attendance',
                            value: attendance,
                            icon: Icons.fact_check_outlined,
                          ),
                          const SizedBox(height: 14),
                          _ProfileInfoCard(
                            title: 'Parent / Guardian',
                            value: parentName,
                            icon: Icons.family_restroom_outlined,
                          ),
                          const SizedBox(height: 14),
                          _ProfileInfoCard(
                            title: 'Email',
                            value: email,
                            icon: Icons.mail_outline_rounded,
                          ),
                          const SizedBox(height: 14),
                          _ProfileInfoCard(
                            title: 'Phone Number',
                            value: phone,
                            icon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 18),
                          const _SettingsSection(),
                          const SizedBox(height: 20),
                          AppButton(
                            text: 'Logout',
                            backgroundColor: const Color(0xFFF0C7C7),
                            textColor: AppColors.textBlack,
                            onTap: () => LogoutHelper.logout(context),
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

class _ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProfileInfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderBlue, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFD7DDF4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings & Preferences',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 12),
          _SettingTile(
            title: 'Edit Profile',
            icon: Icons.edit_outlined,
            onTap: () {},
          ),
          const Divider(color: AppColors.borderSoft, height: 24),
          _SettingTile(
            title: 'Change Password',
            icon: Icons.lock_outline_rounded,
            onTap: () {},
          ),
          const Divider(color: AppColors.borderSoft, height: 24),
          _SettingTile(
            title: 'App Notifications',
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textBlack, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}