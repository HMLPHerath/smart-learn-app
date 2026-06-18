import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/top_blue_header.dart';
import '../../data/models/guide_book_model.dart';
import '../../di/injection.dart';

class UploadGuideBookScreen extends StatefulWidget {
  const UploadGuideBookScreen({super.key});

  @override
  State<UploadGuideBookScreen> createState() => _UploadGuideBookScreenState();
}

class _UploadGuideBookScreenState extends State<UploadGuideBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  PlatformFile? _selectedFile;

  String _selectedCategory = 'All';
  String _selectedIcon = 'book';
  String _selectedColor = '#D7DDF4';

  bool _isSubmitting = false;

  final List<String> _categories = ['All', 'Recent', 'Popular'];
  
  final Map<String, String> _icons = {
    'Book': 'book',
    'Database/Storage': 'storage',
    'Math/Functions': 'functions',
    'Science/Physics': 'science',
    'Computer/ICT': 'computer',
  };

  final Map<String, String> _colors = {
    'Soft Blue': '#D7DDF4',
    'Soft Yellow': '#F5DE9B',
    'Soft Green': '#CBE8C7',
    'Soft Red': '#FAD2E1',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedFile == null || _selectedFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // First upload the file
    final fileUrl = await contentRepository.uploadFile(_selectedFile!.bytes!, _selectedFile!.name);

    if (fileUrl == null) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload file to server. Please try again.')),
        );
      }
      return;
    }

    final book = GuideBookModel(
      bookId: 0,
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      iconName: _selectedIcon,
      colorHex: _selectedColor,
      fileUrl: fileUrl,
      category: _selectedCategory,
    );

    final success = await contentRepository.addGuideBook(book);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guide book uploaded successfully!')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload guide book. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    'Upload Guide Book',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Book Title'),
                      _buildTextField(_titleController, 'Enter book title', required: true),
                      const SizedBox(height: 16),
                      
                      _buildLabel('Subtitle / Description'),
                      _buildTextField(_subtitleController, 'Enter short description', required: true),
                      const SizedBox(height: 16),
                      
                      _buildLabel('Category'),
                      _buildDropdown(
                        value: _selectedCategory,
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val as String),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildLabel('Cover Icon'),
                      _buildDropdown(
                        value: _selectedIcon,
                        items: _icons.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
                        onChanged: (val) => setState(() => _selectedIcon = val as String),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildLabel('Cover Color'),
                      _buildDropdown(
                        value: _selectedColor,
                        items: _colors.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
                        onChanged: (val) => setState(() => _selectedColor = val as String),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildLabel('PDF File'),
                      InkWell(
                        onTap: _pickFile,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSoft),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryBlue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedFile != null ? _selectedFile!.name : 'Choose PDF File...',
                                  style: TextStyle(
                                    color: _selectedFile != null ? AppColors.textBlack : AppColors.mutedText,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Upload Book', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool required = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
      ),
      validator: required
          ? (val) => (val == null || val.isEmpty) ? 'This field is required' : null
          : null,
    );
  }

  Widget _buildDropdown({required String value, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
      ),
    );
  }
}
