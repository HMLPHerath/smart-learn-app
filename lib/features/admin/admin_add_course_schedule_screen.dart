import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../di/injection.dart';
import '../../data/models/schedule_form_models.dart';

class AdminAddCourseScheduleScreen extends StatefulWidget {
  const AdminAddCourseScheduleScreen({super.key});

  @override
  State<AdminAddCourseScheduleScreen> createState() => _AdminAddCourseScheduleScreenState();
}

class _AdminAddCourseScheduleScreenState extends State<AdminAddCourseScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;

  List<DropdownClassModel> _classes = [];
  List<DropdownTeacherModel> _teachers = [];
  List<DropdownCourseModel> _courses = [];

  String? _selectedClassId;
  String? _selectedTeacherId;
  String? _selectedCourseId;
  String? _selectedDayOfWeek;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final TextEditingController _roomController = TextEditingController();

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    final classes = await adminRepository.getClasses();
    final teachers = await adminRepository.getTeachers();
    final courses = await adminRepository.getCourses();

    if (mounted) {
      setState(() {
        _classes = classes;
        _teachers = teachers;
        _courses = courses;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00'; // formatting to match SQL TIME
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Start and End Times')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await adminRepository.addCourseSchedule(
      classId: _selectedClassId!,
      courseId: _selectedCourseId!,
      teacherId: _selectedTeacherId!,
      dayOfWeek: _selectedDayOfWeek!,
      startTime: _formatTime(_startTime!),
      endTime: _formatTime(_endTime!),
      roomIdentifier: _roomController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course Schedule successfully added!')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add schedule. Please try again.')),
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
            child: Column(
              children: [
                TopBlueHeader(
                  height: 120,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Schedule a Course',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDropdown(
                                  label: 'Class',
                                  value: _selectedClassId,
                                  items: _classes.map((c) {
                                    return DropdownMenuItem(
                                      value: c.classId,
                                      child: Text(c.className),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedClassId = val as String?),
                                ),
                                const SizedBox(height: 16),
                                _buildDropdown(
                                  label: 'Course (Subject)',
                                  value: _selectedCourseId,
                                  items: _courses.map((c) {
                                    return DropdownMenuItem(
                                      value: c.courseId,
                                      child: Text(c.courseName),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedCourseId = val as String?),
                                ),
                                const SizedBox(height: 16),
                                _buildDropdown(
                                  label: 'Teacher',
                                  value: _selectedTeacherId,
                                  items: _teachers.map((t) {
                                    return DropdownMenuItem(
                                      value: t.teacherId,
                                      child: Text(t.fullName),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedTeacherId = val as String?),
                                ),
                                const SizedBox(height: 16),
                                _buildDropdown(
                                  label: 'Day of Week',
                                  value: _selectedDayOfWeek,
                                  items: _daysOfWeek.map((d) {
                                    return DropdownMenuItem(
                                      value: d,
                                      child: Text(d),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedDayOfWeek = val as String?),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTimePicker(
                                        label: 'Start Time',
                                        time: _startTime,
                                        onTap: () => _selectTime(context, true),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildTimePicker(
                                        label: 'End Time',
                                        time: _endTime,
                                        onTap: () => _selectTime(context, false),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  label: 'Room Identifier (e.g. Lab 1, Room 202)',
                                  controller: _roomController,
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: _isSaving ? null : _saveSchedule,
                                    child: _isSaving
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                            'Save Schedule',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required void Function(dynamic) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<dynamic>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
          validator: (val) => val == null ? 'Please select $label' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSoft),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSoft),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSoft),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderSoft),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time != null ? time.format(context) : 'Select',
                  style: TextStyle(
                    fontSize: 16,
                    color: time != null ? AppColors.textBlack : AppColors.mutedText,
                  ),
                ),
                const Icon(Icons.access_time_rounded, color: AppColors.mutedText, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
