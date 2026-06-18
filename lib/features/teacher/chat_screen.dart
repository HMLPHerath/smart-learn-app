import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/route_names.dart';
import '../../core/widgets/search_box.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../data/repositories/chat_local_repository.dart';
import '../../di/injection.dart';

class TeacherChatScreen extends StatefulWidget {
  const TeacherChatScreen({super.key});

  @override
  State<TeacherChatScreen> createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends State<TeacherChatScreen> {
  bool _isLoading = true;
  List<ParentContact> _allContacts = [];
  List<ParentContact> _filteredContacts = [];
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Unread', 'Important'

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final uid = authRepository.currentUser?.uid;
    if (uid == null) return;

    final contacts = await chatLocalRepository.getParentsForTeacher(uid);
    if (mounted) {
      setState(() {
        _allContacts = contacts;
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
    List<ParentContact> temp = _allContacts;

    if (_selectedFilter == 'Unread') {
      temp = temp.where((c) => c.unreadCount > 0).toList();
    } else if (_selectedFilter == 'Important') {
      // Mock logic for Important filter, could just be empty for now
    }

    if (_searchQuery.isNotEmpty) {
      temp = temp.where((c) {
        return c.fullName.toLowerCase().contains(_searchQuery) ||
               c.studentName.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    setState(() {
      _filteredContacts = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      'Messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Chat with parents',
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
                      hintText: 'Search parent or student',
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
                          text: 'Unread',
                          isSelected: _selectedFilter == 'Unread',
                          baseColor: const Color(0xFFF5DE9B),
                          onTap: () => _onFilterChanged('Unread'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          text: 'Important',
                          isSelected: _selectedFilter == 'Important',
                          baseColor: const Color(0xFFCBE8C7),
                          onTap: () => _onFilterChanged('Important'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_filteredContacts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Text(
                          'No contacts found.',
                          style: TextStyle(color: AppColors.mutedText, fontSize: 16),
                        ),
                      )
                    else
                      ..._filteredContacts.map(
                        (contact) => _ChatTile(
                          contact: contact,
                          onTap: () async {
                            // Push to conversation and await pop to refresh contacts
                            await context.push('/teacher/chat/${contact.parentId}', extra: contact);
                            _loadContacts(); // Refresh messages when back
                          },
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

class _ChatTile extends StatelessWidget {
  final ParentContact contact;
  final VoidCallback onTap;

  const _ChatTile({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasUnread = contact.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
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
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFD7DDF4),
                  backgroundImage: contact.profilePictureUri != null && contact.profilePictureUri!.isNotEmpty
                    ? NetworkImage(contact.profilePictureUri!)
                    : null,
                  child: contact.profilePictureUri == null || contact.profilePictureUri!.isEmpty
                    ? const Icon(Icons.person, color: AppColors.primaryBlue)
                    : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                      Text(
                        contact.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Parent of ${contact.studentName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.lastMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textBlack,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 10),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              contact.unreadCount.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: isSelected ? null : Border.all(color: const Color(0xFFE0E5F2)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.textBlack : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}
