import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../di/injection.dart';

class PostNoticeScreen extends StatefulWidget {
  const PostNoticeScreen({super.key});

  @override
  State<PostNoticeScreen> createState() => _PostNoticeScreenState();
}

class _PostNoticeScreenState extends State<PostNoticeScreen> {
  final _noticeIdController = TextEditingController();
  final _authorIdController = TextEditingController();
  final _subjectController = TextEditingController();
  final _audienceController = TextEditingController(text: 'All');
  final _bodyController = TextEditingController();

  bool _isUrgent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _noticeIdController.dispose();
    _authorIdController.dispose();
    _subjectController.dispose();
    _audienceController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submitNotice() async {
    if (_subjectController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject and Body are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await noticeRepository.addNotice({
      'authorId': 'ADM-2026-0001', // Fallback to current admin
      'subject': _subjectController.text.trim(),
      'audience': _audienceController.text.trim(),
      'noticeBody': _bodyController.text.trim(),
      'isUrgent': _isUrgent,
    });

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice posted successfully!')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post notice. Please try again.')),
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
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
              : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 28),
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
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => context.pop(),
                            ),
                            const Text(
                              'Post Notice',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 48, top: 6),
                          child: Text(
                            'Publish updates for students, parents and teachers',
                            style: TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _NoticeFormCard(
                          subjectController: _subjectController,
                          audienceController: _audienceController,
                          bodyController: _bodyController,
                          isUrgent: _isUrgent,
                          onUrgentChanged: (val) => setState(() => _isUrgent = val),
                        ),
                        const SizedBox(height: 18),
                        AppButton(
                          text: 'Post Notice',
                          onTap: _submitNotice,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeFormCard extends StatefulWidget {
  final TextEditingController subjectController;
  final TextEditingController audienceController;
  final TextEditingController bodyController;
  final bool isUrgent;
  final ValueChanged<bool> onUrgentChanged;

  const _NoticeFormCard({
    required this.subjectController,
    required this.audienceController,
    required this.bodyController,
    required this.isUrgent,
    required this.onUrgentChanged,
  });

  @override
  State<_NoticeFormCard> createState() => _NoticeFormCardState();
}

class _NoticeFormCardState extends State<_NoticeFormCard> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderBlue, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const _SectionTitle(title: 'Notice Information'),
          const SizedBox(height: 14),
          AppTextField(
            controller: widget.subjectController,
            label: 'Subject',
            hintText: 'Enter notice title',
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Audience',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: widget.audienceController.text,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderBlue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderBlue),
                  ),
                ),
                items: ['All', 'Students', 'Parents', 'Teachers']
                    .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    widget.audienceController.text = val;
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: widget.bodyController,
            label: 'Notice Body',
            hintText: 'Write the full notice content here',
            maxLines: 6,
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            value: widget.isUrgent,
            onChanged: widget.onUrgentChanged,
            activeColor: AppColors.primaryBlue,
            title: const Text('Mark as urgent', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('This notice will be highlighted in the dashboard'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }
}