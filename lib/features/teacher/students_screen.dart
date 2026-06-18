import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/search_box.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../di/injection.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Active', 'Pending'

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final uid = authRepository.currentUser?.uid;
    if (uid == null) return;

    final students = await teacherRepository.getStudentsForTeacher(uid);
    if (mounted) {
      setState(() {
        _allStudents = students;
        _isLoading = false;
      });
      _applyFilters();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
    _applyFilters();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> temp = _allStudents;

    // Apply Status Filter
    if (_selectedFilter != 'All') {
      temp = temp.where((s) => s['AccountStatus'] == _selectedFilter).toList();
    }

    // Apply Search Filter
    if (_searchQuery.isNotEmpty) {
      temp = temp.where((s) {
        final name = (s['FullName'] ?? '').toLowerCase();
        final id = (s['StudentID'] ?? '').toLowerCase();
        return name.contains(_searchQuery) || id.contains(_searchQuery);
      }).toList();
    }

    setState(() {
      _filteredStudents = temp;
    });
  }

  Color _getStatusColor(String status) {
    if (status == 'Active') return const Color(0xFFCBE8C7);
    if (status == 'Pending') return const Color(0xFFF5DE9B);
    if (status == 'Suspended') return const Color(0xFFF0C7C7);
    return const Color(0xFFEEEEEE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Removed the FAB as teachers do not add students
      body: SafeArea(
        child: _isLoading
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
                  children: const [
                    Text(
                      'Students',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Manage student directory',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    SearchBox(
                      hintText: 'Search students by name or ID',
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _FilterChip(
                          text: 'All',
                          isSelected: _selectedFilter == 'All',
                          baseColor: const Color(0xFFD7DDF4),
                          onTap: () => _onFilterChanged('All'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          text: 'Active',
                          isSelected: _selectedFilter == 'Active',
                          baseColor: const Color(0xFFCBE8C7),
                          onTap: () => _onFilterChanged('Active'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          text: 'Pending',
                          isSelected: _selectedFilter == 'Pending',
                          baseColor: const Color(0xFFF5DE9B),
                          onTap: () => _onFilterChanged('Pending'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_filteredStudents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Text(
                          'No students found.',
                          style: TextStyle(color: AppColors.mutedText, fontSize: 16),
                        ),
                      )
                    else
                      ..._filteredStudents.map(
                        (student) => _StudentTile(
                          name: student['FullName'] ?? 'Unknown',
                          id: student['StudentID'] ?? 'N/A',
                          className: student['ClassName'] ?? 'No Class',
                          status: student['AccountStatus'] ?? 'Pending',
                          statusColor: _getStatusColor(student['AccountStatus'] ?? ''),
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

class _StudentTile extends StatelessWidget {
  final String name;
  final String id;
  final String className;
  final String status;
  final Color statusColor;

  const _StudentTile({
    required this.name,
    required this.id,
    required this.className,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFD7DDF4),
            child: Icon(Icons.person, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  id,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  className,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
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
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.primaryBlue),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Color baseColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.text,
    required this.isSelected,
    required this.baseColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? baseColor : AppColors.borderBlue,
            width: 1.2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColors.textBlack : AppColors.mutedText,
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
