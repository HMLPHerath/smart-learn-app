import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/search_box.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../data/models/course_model.dart';
import '../../di/injection.dart';

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  bool _loading = true;
  List<CourseModel> _allCourses = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final uid = authRepository.currentUser?.uid;
      if (uid != null) {
        final courses = await contentRepository.getStudentSchedule(uid);
        if (mounted) {
          setState(() {
            _allCourses = courses;
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

  String _getCourseStatus(CourseModel course) {
    final now = DateTime.now();
    final todayStr = DateFormat('EEEE').format(now);
    
    if (course.dayOfWeek == todayStr) {
      try {
        final startTime = DateFormat("hh:mma").parse(course.startTime.replaceAll(' ', ''));
        final endTime = DateFormat("hh:mma").parse(course.endTime.replaceAll(' ', ''));
        
        final nowTime = DateTime(1970, 1, 1, now.hour, now.minute);
        final sTime = DateTime(1970, 1, 1, startTime.hour, startTime.minute);
        final eTime = DateTime(1970, 1, 1, endTime.hour, endTime.minute);
        
        if (nowTime.isAfter(sTime) && nowTime.isBefore(eTime)) return 'LIVE';
        if (nowTime.isAfter(eTime)) return 'ENDED';
      } catch(e) {}
      return 'TODAY';
    }
    return course.dayOfWeek.toUpperCase();
  }

  IconData _getIconForSubject(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return Icons.functions_rounded;
    if (s.contains('science')) return Icons.science_outlined;
    if (s.contains('english')) return Icons.menu_book_outlined;
    if (s.contains('ict') || s.contains('computer') || s.contains('information')) return Icons.computer_rounded;
    if (s.contains('history')) return Icons.history_edu_rounded;
    if (s.contains('commerce')) return Icons.monetization_on_outlined;
    if (s.contains('geography')) return Icons.public_rounded;
    if (s.contains('art')) return Icons.palette_outlined;
    if (s.contains('music')) return Icons.music_note_rounded;
    if (s.contains('database')) return Icons.storage_rounded;
    return Icons.book_rounded;
  }

  Color _getColorForStatus(String status) {
    if (status == 'LIVE') return const Color(0xFFCBE8C7);
    if (status == 'TODAY') return const Color(0xFFF5DE9B);
    return const Color(0xFFD7DDF4);
  }

  @override
  Widget build(BuildContext context) {
    List<CourseModel> filteredCourses = _allCourses.where((c) {
      if (_selectedFilter == 'All') return true;
      final status = _getCourseStatus(c);
      if (_selectedFilter == 'Today') return status == 'TODAY' || status == 'LIVE' || status == 'ENDED';
      if (_selectedFilter == 'Live') return status == 'LIVE';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  children: [
                    TopBlueHeader(
                      height: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Text(
                            'Courses',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Explore your daily subjects',
                            style: TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const SearchBox(hintText: 'Search courses'),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _FilterChip(
                                text: 'All',
                                isSelected: _selectedFilter == 'All',
                                onTap: () => setState(() => _selectedFilter = 'All'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                text: 'Today',
                                isSelected: _selectedFilter == 'Today',
                                onTap: () => setState(() => _selectedFilter = 'Today'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                text: 'Live',
                                isSelected: _selectedFilter == 'Live',
                                onTap: () => setState(() => _selectedFilter = 'Live'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          if (filteredCourses.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Text('No courses found for this filter.', style: TextStyle(color: AppColors.mutedText)),
                            ),
                          ...filteredCourses.map((course) {
                            final status = _getCourseStatus(course);
                            return _CourseTile(
                              title: course.title,
                              teacher: course.teacherName,
                              time: '${course.startTime} - ${course.endTime}',
                              status: status,
                              chipColor: _getColorForStatus(status),
                              icon: _getIconForSubject(course.title),
                            );
                          }).toList(),
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

class _CourseTile extends StatelessWidget {
  final String title;
  final String teacher;
  final String time;
  final String status;
  final Color chipColor;
  final IconData icon;

  const _CourseTile({
    required this.title,
    required this.teacher,
    required this.time,
    required this.status,
    required this.chipColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  teacher,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        time,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD7DDF4) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: isSelected ? null : Border.all(color: AppColors.borderBlue),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primaryBlue : AppColors.mutedText,
          ),
        ),
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