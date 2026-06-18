import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../data/models/guide_book_model.dart';
import '../../di/injection.dart';

class TeacherGuideBooksScreen extends StatefulWidget {
  const TeacherGuideBooksScreen({super.key});

  @override
  State<TeacherGuideBooksScreen> createState() => _TeacherGuideBooksScreenState();
}

class _TeacherGuideBooksScreenState extends State<TeacherGuideBooksScreen> {
  bool _isLoading = true;
  List<GuideBookModel> _books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });
    final books = await contentRepository.getGuideBooks();
    setState(() {
      _books = books;
      _isLoading = false;
    });
  }

  IconData _getIcon(String name) {
    switch (name.toLowerCase()) {
      case 'storage': return Icons.storage_rounded;
      case 'functions': return Icons.functions_rounded;
      case 'science': return Icons.science_outlined;
      case 'computer': return Icons.computer_outlined;
      case 'book':
      default:
        return Icons.menu_book_outlined;
    }
  }

  Color _getColor(String hex) {
    String cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    return Color(int.parse('0x$cleanHex'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(RouteNames.teacherAddBook);
          // Reload books when coming back
          _loadBooks();
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TopBlueHeader(
              height: 140,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Manage Guide Books',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _books.isEmpty
                      ? const Center(child: Text('No guide books uploaded yet'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(18),
                          itemCount: _books.length,
                          itemBuilder: (context, index) {
                            final book = _books[index];
                            return _BookTile(
                              title: book.title,
                              subtitle: book.subtitle,
                              icon: _getIcon(book.iconName),
                              iconBg: _getColor(book.colorHex),
                              category: book.category,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final String category;

  const _BookTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderBlue, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBg,
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
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedText,
                  ),
                ),
                if (category.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Category: $category',
                      style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue),
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
