import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../di/injection.dart';

class ParentResultScreen extends StatefulWidget {
  const ParentResultScreen({super.key});

  @override
  State<ParentResultScreen> createState() => _ParentResultScreenState();
}

class _ParentResultScreenState extends State<ParentResultScreen> {
  bool _loading = true;
  Map<String, dynamic>? _resultsData;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final uid = authRepository.currentUser?.uid;
      if (uid != null) {
        final data = await parentRepository.getParentChildResults(uid);
        if (mounted) {
          setState(() {
            _resultsData = data;
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
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    final term = _resultsData?['term'] ?? 'N/A';
    final year = _resultsData?['year'] ?? '';
    final average = _resultsData?['average'] ?? 0;
    final rank = _resultsData?['rank'] ?? 'N/A';
    final resultsList = _resultsData?['results'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            children: [
              TopBlueHeader(
                height: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Exam Results',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$term • $year',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Average',
                            value: '$average%',
                            icon: Icons.auto_graph_outlined,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _StatCard(
                            title: 'Rank',
                            value: rank,
                            icon: Icons.emoji_events_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _PerformanceOverview(resultsList: resultsList),
                    const SizedBox(height: 18),
                    if (resultsList.isEmpty)
                      const Center(child: Text("No results found"))
                    else
                      ...resultsList.map((res) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _SubjectResultCard(
                            subject: res['CourseName'] ?? 'Unknown',
                            marks: res['RawMarks'].toString(),
                            grade: res['GradeLetter'] ?? 'N/A',
                          ),
                        );
                      }),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerformanceOverview extends StatelessWidget {
  final List<dynamic> resultsList;

  const _PerformanceOverview({required this.resultsList});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderBlue, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 180,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: resultsList.map((res) {
                // Determine bar color based on grade
                Color barColor = const Color(0xFFCBE8C7); // Default Green (A)
                if (res['GradeLetter'] == 'B' || res['GradeLetter'] == 'B+') {
                  barColor = const Color(0xFFD7DDF4); // Blue (B)
                } else if (res['GradeLetter'] == 'C' || res['GradeLetter'] == 'C+') {
                  barColor = const Color(0xFFF6E4A8); // Yellow (C)
                } else if (res['GradeLetter'] == 'S' || res['GradeLetter'] == 'W' || res['GradeLetter'] == 'F') {
                  barColor = const Color(0xFFF0C7C7); // Red (Low)
                }
                
                // Get short name for subject
                String subj = res['CourseName'] ?? 'Sub';
                if (subj.length > 4) {
                   subj = subj.substring(0, 4);
                }

                double rawMarks = double.tryParse(res['RawMarks']?.toString() ?? '0') ?? 0.0;
                double heightPct = rawMarks / 100.0;
                double barHeight = 100 * heightPct;
                if (barHeight < 10) barHeight = 10;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subj,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectResultCard extends StatelessWidget {
  final String subject;
  final String marks;
  final String grade;

  const _SubjectResultCard({
    required this.subject,
    required this.marks,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    Color gradeColor;
    if (grade.startsWith('A')) {
      gradeColor = const Color(0xFFCBE8C7);
    } else if (grade.startsWith('B')) {
      gradeColor = const Color(0xFFD7DDF4);
    } else if (grade.startsWith('C')) {
      gradeColor = const Color(0xFFF6E4A8);
    } else {
      gradeColor = const Color(0xFFF0C7C7);
    }

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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E7FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Marks: $marks',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: gradeColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              grade,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
