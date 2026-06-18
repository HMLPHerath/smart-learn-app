import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../data/models/course_model.dart';
import '../../di/injection.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  bool _loading = true;
  List<CourseModel> _allCourses = [];
  
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _initDates();
    _loadSchedule();
  }

  void _initDates() {
    final now = DateTime.now();
    _selectedDate = now;
    // Calculate Monday of current week
    final int currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final DateTime monday = now.subtract(Duration(days: currentWeekday - 1));
    
    _weekDates = List.generate(5, (index) => monday.add(Duration(days: index))); 
  }

  Future<void> _loadSchedule() async {
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

  String _getCourseStatus(CourseModel course, DateTime selectedDate) {
    final now = DateTime.now();
    // Only calculate 'NOW', 'ENDED', 'NEXT' if selected date is today
    if (selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day) {
      try {
        final startTime = DateFormat("hh:mma").parse(course.startTime.replaceAll(' ', ''));
        final endTime = DateFormat("hh:mma").parse(course.endTime.replaceAll(' ', ''));
        
        final nowTime = DateTime(1970, 1, 1, now.hour, now.minute);
        final sTime = DateTime(1970, 1, 1, startTime.hour, startTime.minute);
        final eTime = DateTime(1970, 1, 1, endTime.hour, endTime.minute);
        
        if (nowTime.isAfter(sTime) && nowTime.isBefore(eTime)) return 'NOW';
        if (nowTime.isAfter(eTime)) return 'ENDED';
        if (nowTime.isBefore(sTime)) return 'NEXT';
      } catch(e) {}
    }
    return 'UPCOMING';
  }

  Color _getColorForStatus(String status) {
    if (status == 'NOW') return const Color(0xFFCBE8C7);
    if (status == 'ENDED') return const Color(0xFFF5DE9B);
    if (status == 'NEXT') return const Color(0xFFD7DDF4);
    return const Color(0xFFE2E8F0);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayString = DateFormat('EEEE').format(_selectedDate); 
    
    // Filter courses for selected day
    final dayCourses = _allCourses.where((c) => c.dayOfWeek == selectedDayString).toList();

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
                      height: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Schedule',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Today • ${DateFormat('EEEE').format(DateTime.now())}',
                            style: const TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _weekDates.map((date) {
                              final isSelected = date.year == _selectedDate.year && 
                                                 date.month == _selectedDate.month && 
                                                 date.day == _selectedDate.day;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedDate = date),
                                child: _DateChip(
                                  day: DateFormat('EEE').format(date),
                                  date: DateFormat('d').format(date),
                                  selected: isSelected,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                          if (dayCourses.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Text('No classes scheduled for this day.', style: TextStyle(color: AppColors.mutedText)),
                            ),
                          ...dayCourses.map((course) {
                            final status = _getCourseStatus(course, _selectedDate);
                            return _ScheduleTimelineTile(
                              subject: course.title,
                              teacher: course.teacherName,
                              time: '${course.startTime} - ${course.endTime}',
                              status: status,
                              chipColor: _getColorForStatus(status),
                              room: course.roomIdentifier.isNotEmpty ? course.roomIdentifier : 'Class Room / Lab',
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

class _DateChip extends StatelessWidget {
  final String day;
  final String date;
  final bool selected;

  const _DateChip({
    required this.day,
    required this.date,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderBlue, width: 1.2),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white70 : AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTimelineTile extends StatelessWidget {
  final String subject;
  final String teacher;
  final String time;
  final String status;
  final Color chipColor;
  final String room;

  const _ScheduleTimelineTile({
    required this.subject,
    required this.teacher,
    required this.time,
    required this.status,
    required this.chipColor,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 2, height: 126, color: const Color(0xFFD7DDF4)),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: _box(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  teacher,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          room,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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