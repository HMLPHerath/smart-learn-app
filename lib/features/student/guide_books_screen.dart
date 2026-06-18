import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/search_box.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../data/models/guide_book_model.dart';
import '../../di/injection.dart';

class StudentGuideBooksScreen extends StatefulWidget {
  const StudentGuideBooksScreen({super.key});

  @override
  State<StudentGuideBooksScreen> createState() => _StudentGuideBooksScreenState();
}

class _StudentGuideBooksScreenState extends State<StudentGuideBooksScreen> {
  bool _isLoading = true;
  List<GuideBookModel> _allBooks = [];
  List<GuideBookModel> _filteredBooks = [];

  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final books = await contentRepository.getGuideBooks();
    setState(() {
      _allBooks = books;
      _filteredBooks = books;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredBooks = _allBooks.where((book) {
      final matchesCategory = _selectedCategory == 'All' || book.category.toLowerCase() == _selectedCategory.toLowerCase() || book.category.isEmpty;
      final matchesSearch = _searchQuery.isEmpty || 
                            book.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            book.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
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
      body: SafeArea(
        child: Column(
          children: [
            TopBlueHeader(
              height: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Guide Books',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Browse recommended study books',
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
                    hintText: 'Search guide books',
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _FilterChip(
                        text: 'All',
                        isSelected: _selectedCategory == 'All',
                        onTap: () => _onCategorySelected('All'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        text: 'Recent',
                        isSelected: _selectedCategory == 'Recent',
                        onTap: () => _onCategorySelected('Recent'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        text: 'Popular',
                        isSelected: _selectedCategory == 'Popular',
                        onTap: () => _onCategorySelected('Popular'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredBooks.isEmpty
                      ? const Center(child: Text('No guide books found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: _filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = _filteredBooks[index];
                            return _BookTile(
                              title: book.title,
                              subtitle: book.subtitle,
                              icon: _getIcon(book.iconName),
                              iconBg: _getColor(book.colorHex),
                              onTap: () async {
                                final url = Uri.parse(book.fileUrl);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Could not open the file link.')),
                                    );
                                  }
                                }
                              },
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
  final VoidCallback? onTap;

  const _BookTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: _box(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
        ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD7DDF4) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderBlue,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primaryBlue : AppColors.textBlack,
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