import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../di/injection.dart';
import '../../data/models/teacher_model.dart';
import '../../data/models/course_model.dart';
import '../../data/models/notice_model.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  bool _loading = true;
  TeacherModel? _teacher;
  List<CourseModel> _courses = [];
  List<NoticeModel> _notices = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = authRepository.currentUser?.uid;
      if (uid != null) {
        final teacher = await teacherRepository.getTeacherById(uid);
        final courses = await contentRepository.getCourses();
        final notices = await noticeRepository.getNotices();
        
        if (mounted) {
          setState(() {
            _teacher = teacher;
            _courses = courses;
            _notices = notices;
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
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _teacher?.fullName ?? 'Teacher';
    final subject = _teacher?.subject ?? 'Subject Teacher';
    final className = _teacher?.className ?? 'General Class';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
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
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.18),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $name',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$subject Teacher • $className',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    /// top stats
                    Row(
                      children: [
                        Expanded(
                          child: _TopStatCard(
                            title: 'Total Courses',
                            value: _courses.length.toString(),
                            icon: Icons.menu_book_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: _TopStatCard(
                            title: 'Students',
                            value: 'Active',
                            icon: Icons.groups_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// quick actions
                    Row(
                      children: [
                        Expanded(
                          child: _QuickCard(
                            title: 'Attendance',
                            icon: Icons.fact_check_outlined,
                            onTap: () =>
                                context.push(RouteNames.teacherAttendance),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickCard(
                            title: 'Gradebook',
                            icon: Icons.auto_graph_outlined,
                            onTap: () =>
                                context.push(RouteNames.teacherGradebook),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickCard(
                            title: 'Guide Books',
                            icon: Icons.menu_book_outlined,
                            onTap: () => context.push(RouteNames.teacherBooks),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickCard(
                            title: 'Messages',
                            icon: Icons.chat_bubble_outline,
                            onTap: () => context.go(RouteNames.teacherShell),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()), // Placeholder for alignment
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()), // Placeholder for alignment
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// upcoming class
                    _SectionCard(
                      title: 'My Courses',
                      child: Column(
                        children: _courses.isEmpty
                            ? [const Text('No courses assigned', style: TextStyle(color: AppColors.mutedText))]
                            : _courses.take(2).map((c) => Column(
                                children: [
                                  _ScheduleTile(
                                    subject: c.title,
                                    time: '${c.startTime} - ${c.endTime}',
                                    room: 'Status: ${c.status}',
                                    chip: c.status == 'Active' ? 'NOW' : 'NEXT',
                                    chipColor: c.status == 'Active' ? const Color(0xFFCBE8C7) : const Color(0xFFD7DDF4),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              )).toList(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// pending tasks
                    _SectionCard(
                      title: 'System Notices',
                      child: Column(
                        children: _notices.isEmpty
                            ? [const Text('No recent notices', style: TextStyle(color: AppColors.mutedText))]
                            : _notices.take(3).map((n) => Column(
                                children: [
                                  _TaskTile(
                                    title: n.subject,
                                    subtitle: n.body.length > 30 ? '${n.body.substring(0, 30)}...' : n.body,
                                    icon: Icons.info_outline,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              )).toList(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// class progress
                    const _SectionCard(
                      title: 'Class Progress',
                      child: Row(
                        children: [
                          Expanded(
                            child: _ProgressMini(
                              title: 'Attendance',
                              value: '96%',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _ProgressMini(
                              title: 'Avg Marks',
                              value: '82%',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _ProgressMini(
                              title: 'Submitted',
                              value: '88%',
                            ),
                          ),
                        ],
                      ),
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

class _TopStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _TopStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
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

class _QuickCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: _box(),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final String subject;
  final String time;
  final String room;
  final String chip;
  final Color chipColor;

  const _ScheduleTile({
    required this.subject,
    required this.time,
    required this.room,
    required this.chip,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _innerBox(),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  room,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _Chip(text: chip, color: chipColor),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _TaskTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _innerBox(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFD7DDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.primaryBlue),
        ],
      ),
    );
  }
}

class _ProgressMini extends StatelessWidget {
  final String title;
  final String value;

  const _ProgressMini({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: _innerBox(),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;

  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
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

BoxDecoration _innerBox() {
  return BoxDecoration(
    color: const Color(0xFFF9F9F9),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.borderSoft),
  );
}
