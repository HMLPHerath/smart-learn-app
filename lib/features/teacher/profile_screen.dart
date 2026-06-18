import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/logout_helper.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/circular_avatar.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../di/injection.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
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
        final profile = await teacherRepository.getTeacherProfile(uid);
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
    // Extract fields with fallbacks
    final fullName = _profileData?['FullName'] ?? 'Teacher Name';
    final teacherId = _profileData?['TeacherID'] ?? authRepository.currentUser?.uid ?? 'TEA-UNKNOWN';
    final specialization = _profileData?['Specialization'] ?? 'General Subject';
    final assignedClasses = _profileData?['AssignedClasses'] ?? 'Not Assigned';
    final email = _profileData?['Email'] ?? 'Not Available';
    final phone = _profileData?['PhoneNumber'] ?? 'Not Available';
    
    // Stats
    final stats = _profileData?['Stats'] ?? {};
    final classCount = (stats['Classes'] ?? 0).toString().padLeft(2, '0');
    final studentCount = (stats['Students'] ?? 0).toString();
    final attendance = stats['Attendance'] ?? 'N/A';
    final avgMarks = stats['AvgMarks'] ?? 'N/A';

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
                            '$teacherId • $specialization',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          ProfileInfoCard(
                            title: 'Full Name',
                            value: fullName,
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 14),
                          ProfileInfoCard(
                            title: 'Teacher ID',
                            value: teacherId,
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 14),
                          ProfileInfoCard(
                            title: 'Subject / Specialization',
                            value: specialization,
                            icon: Icons.menu_book_outlined,
                          ),
                          const SizedBox(height: 14),
                          ProfileInfoCard(
                            title: 'Assigned Classes',
                            value: assignedClasses,
                            icon: Icons.school_outlined,
                          ),
                          const SizedBox(height: 14),
                          ProfileInfoCard(
                            title: 'Email',
                            value: email,
                            icon: Icons.mail_outline_rounded,
                          ),
                          const SizedBox(height: 14),
                          ProfileInfoCard(
                            title: 'Phone Number',
                            value: phone,
                            icon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 18),
                          TeacherStatsSection(
                            classCount: classCount,
                            studentCount: studentCount,
                            attendance: attendance,
                            avgMarks: avgMarks,
                          ),
                          const SizedBox(height: 18),
                          const SettingsSection(),
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

////////////////////////////////////////////////////////////
/// PROFILE INFO CARD
////////////////////////////////////////////////////////////

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ProfileInfoCard({
    super.key,
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

////////////////////////////////////////////////////////////
/// TEACHER STATS
////////////////////////////////////////////////////////////

class TeacherStatsSection extends StatelessWidget {
  final String classCount;
  final String studentCount;
  final String attendance;
  final String avgMarks;

  const TeacherStatsSection({
    super.key,
    required this.classCount,
    required this.studentCount,
    required this.attendance,
    required this.avgMarks,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teaching Summary',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: MiniStatCard(title: 'Classes', value: classCount, icon: Icons.class_outlined)),
              const SizedBox(width: 12),
              Expanded(child: MiniStatCard(title: 'Students', value: studentCount, icon: Icons.groups_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: MiniStatCard(title: 'Attendance', value: attendance, icon: Icons.fact_check_outlined)),
              const SizedBox(width: 12),
              Expanded(child: MiniStatCard(title: 'Avg Marks', value: avgMarks, icon: Icons.auto_graph_outlined)),
            ],
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// MINI STAT CARD
////////////////////////////////////////////////////////////

class MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const MiniStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD7DDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
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

////////////////////////////////////////////////////////////
/// SETTINGS SECTION
////////////////////////////////////////////////////////////

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'Edit Profile', 'icon': Icons.edit_outlined},
      {'title': 'Manage Classes', 'icon': Icons.class_outlined},
      {'title': 'Messages', 'icon': Icons.chat_bubble_outline},
      {'title': 'Help & Support', 'icon': Icons.help_outline_rounded},
    ];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 14),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Container(
              margin: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : 12,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7DDF4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon']! as IconData,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['title']! as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}