import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../di/injection.dart';

class TeacherGradebookScreen extends StatefulWidget {
  const TeacherGradebookScreen({super.key});

  @override
  State<TeacherGradebookScreen> createState() => _TeacherGradebookScreenState();
}

class _TeacherGradebookScreenState extends State<TeacherGradebookScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _students = [];

  String? _selectedClassId;
  String? _selectedClassName;
  
  String? _selectedCourseId;
  String? _selectedCourseName;

  final List<String> _terms = ['Term 01', 'Term 02', 'Term 03'];
  String _selectedTerm = 'Term 01';

  final List<int> _years = [2026, 2027];
  int _selectedYear = 2026;

  // Key: StudentID, Value: Marks
  final Map<String, TextEditingController> _marksControllers = {};
  final Map<String, String> _grades = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final uid = authRepository.currentUser?.uid;
    if (uid == null) return;

    final classes = await gradebookRepository.getClassesForTeacher(uid);
    setState(() {
      _classes = classes;
      if (_classes.isNotEmpty) {
        _selectedClassId = _classes.first['ClassID'];
        _selectedClassName = _classes.first['ClassName'];
      }
    });

    if (_selectedClassId != null) {
      await _loadCoursesForClass(_selectedClassId!);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCoursesForClass(String classId) async {
    setState(() => _isLoading = true);
    final uid = authRepository.currentUser?.uid;
    if (uid == null) return;

    final courses = await gradebookRepository.getCoursesForTeacherAndClass(uid, classId);
    setState(() {
      _courses = courses;
      if (_courses.isNotEmpty) {
        _selectedCourseId = _courses.first['CourseID'];
        _selectedCourseName = _courses.first['CourseName'];
      } else {
        _selectedCourseId = null;
        _selectedCourseName = null;
      }
    });

    if (_selectedCourseId != null) {
      await _loadStudentsAndGrades();
    } else {
      setState(() {
        _students = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStudentsAndGrades() async {
    setState(() => _isLoading = true);

    if (_selectedClassId == null || _selectedCourseId == null) {
      setState(() => _isLoading = false);
      return;
    }

    _students = await gradebookRepository.getStudentsInClass(_selectedClassId!);
    final existingGrades = await gradebookRepository.getGrades(
      _selectedClassId!,
      _selectedCourseId!,
      _selectedTerm,
      _selectedYear,
    );

    _marksControllers.clear();
    _grades.clear();

    for (var student in _students) {
      final sid = student['StudentID'];
      _marksControllers[sid] = TextEditingController();
      _grades[sid] = '-';

      // Find if grade exists
      final existing = existingGrades.where((g) => g['StudentID'] == sid).toList();
      if (existing.isNotEmpty) {
        final marks = existing.first['RawMarks'];
        _marksControllers[sid]!.text = marks.toString();
        _grades[sid] = existing.first['GradeLetter'];
      }
    }

    setState(() => _isLoading = false);
  }

  void _onMarksChanged(String studentId, String value) {
    final marks = double.tryParse(value);
    setState(() {
      if (marks == null) {
        _grades[studentId] = '-';
      } else if (marks >= 85) {
        _grades[studentId] = 'A+';
      } else if (marks >= 75) {
        _grades[studentId] = 'A';
      } else if (marks >= 65) {
        _grades[studentId] = 'B+';
      } else if (marks >= 55) {
        _grades[studentId] = 'B';
      } else if (marks >= 45) {
        _grades[studentId] = 'C+';
      } else if (marks >= 35) {
        _grades[studentId] = 'C';
      } else {
        _grades[studentId] = 'F';
      }
    });
  }

  Future<void> _saveGrades() async {
    if (_selectedCourseId == null) return;
    
    setState(() => _isSaving = true);

    List<Map<String, dynamic>> payload = [];
    for (var sid in _marksControllers.keys) {
      final text = _marksControllers[sid]!.text;
      if (text.isNotEmpty) {
        final marks = double.tryParse(text);
        if (marks != null) {
          payload.add({
            'studentId': sid,
            'marks': marks,
            'gradeLetter': _grades[sid],
          });
        }
      }
    }

    final success = await gradebookRepository.saveGrades(
      _selectedTerm,
      _selectedYear,
      _selectedCourseId!,
      payload,
    );

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Grades saved successfully!' : 'Failed to save grades')),
      );
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return const Color(0xFFCBE8C7);
      case 'B+':
      case 'B':
        return const Color(0xFFD7DDF4);
      case 'C+':
      case 'C':
      case 'S':
        return const Color(0xFFF5DE9B);
      case 'F':
        return const Color(0xFFF0C7C7);
      default:
        return const Color(0xFFEEEEEE);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate average
    double totalMarks = 0;
    int count = 0;
    for (var ctrl in _marksControllers.values) {
      final val = double.tryParse(ctrl.text);
      if (val != null) {
        totalMarks += val;
        count++;
      }
    }
    final average = count > 0 ? (totalMarks / count).toStringAsFixed(1) : '0';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      'Gradebook',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_selectedCourseName ?? "No Course"} • $_selectedTerm',
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    // Summary Row
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Students',
                            value: _students.length.toString(),
                            icon: Icons.groups_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Average',
                            value: '$average%',
                            icon: Icons.auto_graph_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    
                    // Filters
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderBlue, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(labelText: 'Class', isDense: true),
                                  value: _selectedClassId,
                                  items: _classes.map((c) {
                                    return DropdownMenuItem<String>(
                                      value: c['ClassID'],
                                      child: Text(c['ClassName']),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedClassId = val;
                                        _selectedClassName = _classes.firstWhere((c) => c['ClassID'] == val)['ClassName'];
                                      });
                                      _loadCoursesForClass(val);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(labelText: 'Course', isDense: true),
                                  value: _selectedCourseId,
                                  items: _courses.map((c) {
                                    return DropdownMenuItem<String>(
                                      value: c['CourseID'],
                                      child: Text(c['CourseName']),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedCourseId = val;
                                        _selectedCourseName = _courses.firstWhere((c) => c['CourseID'] == val)['CourseName'];
                                      });
                                      _loadStudentsAndGrades();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(labelText: 'Term', isDense: true),
                                  value: _selectedTerm,
                                  items: _terms.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedTerm = val);
                                      _loadStudentsAndGrades();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(labelText: 'Year', isDense: true),
                                  value: _selectedYear,
                                  items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedYear = val);
                                      _loadStudentsAndGrades();
                                    }
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    
                    if (_isLoading)
                      const CircularProgressIndicator(color: AppColors.primaryBlue)
                    else if (_students.isEmpty)
                      const Text('No students found in this class.')
                    else
                      ..._students.map(
                        (item) {
                          final sid = item['StudentID'];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderBlue, width: 1.2),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(radius: 20, child: Icon(Icons.person, size: 20)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['FullName'],
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(sid, style: const TextStyle(fontSize: 12, color: AppColors.mutedText)),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 40,
                                              child: TextField(
                                                controller: _marksControllers[sid],
                                                keyboardType: TextInputType.number,
                                                onChanged: (val) => _onMarksChanged(sid, val),
                                                decoration: InputDecoration(
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                                  hintText: 'Marks',
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            width: 40,
                                            height: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: _getGradeColor(_grades[sid] ?? '-'),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              _grades[sid] ?? '-',
                                              style: const TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 18),
                    if (!_isLoading && _students.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Cancel',
                              backgroundColor: const Color(0xFFF0C7C7),
                              textColor: AppColors.textBlack,
                              onTap: () => _loadStudentsAndGrades(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: _isSaving ? 'Saving...' : 'Save Grades', 
                              onTap: _isSaving ? () {} : _saveGrades
                            ),
                          ),
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderBlue, width: 1.2),
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.mutedText)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textBlack)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
