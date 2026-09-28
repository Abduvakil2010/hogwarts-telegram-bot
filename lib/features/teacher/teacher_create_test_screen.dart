import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/media_image.dart';
import '../../data/models/test_model.dart';
import '../../data/repositories/database_repository.dart';

class TeacherCreateTestScreen extends StatefulWidget {
  final String teacherId;

  const TeacherCreateTestScreen({
    super.key,
    required this.teacherId,
  });

  @override
  State<TeacherCreateTestScreen> createState() => _TeacherCreateTestScreenState();
}

class _TeacherCreateTestScreenState extends State<TeacherCreateTestScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final DatabaseRepository _db = DatabaseRepository();
  final Uuid _uuid = const Uuid();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedGroupId;
  String? _selectedImagePath;
  int _questionCount = 5;
  final Map<int, String> _correctAnswers = {};
  bool _isLoading = false;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    final groups = _db.getTeacherGroups(widget.teacherId);
    if (groups.isNotEmpty) {
      _selectedGroupId = groups.first.groupId;
    }
    for (int i = 1; i <= _questionCount; i++) {
      _correctAnswers[i] = 'A';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _onQuestionCountChanged(int count) {
    setState(() {
      _questionCount = count;
      for (int i = 1; i <= count; i++) {
        _correctAnswers.putIfAbsent(i, () => 'A');
      }
    });
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (picked != null) {
      if (kIsWeb) {
        try {
          final bytes = await picked.readAsBytes();
          final name = picked.name;
          final ext = name.contains('.') ? name.split('.').last.toLowerCase() : 'png';
          final mime = (ext == 'jpg' || ext == 'jpeg') ? 'image/jpeg' : (ext == 'png' ? 'image/png' : 'image/png');
          final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';
          setState(() {
            _selectedImagePath = dataUri;
            _imageUrlController.text = dataUri;
          });
        } catch (_) {
          // fallback to nothing
        }
      } else {
        setState(() {
          _selectedImagePath = picked.path;
          _imageUrlController.text = picked.path;
        });
      }
    }
  }

  Future<void> _saveTest() async {
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      setState(() => _titleError = l10n.requiredField);
      return;
    }

    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, guruhni tanlang')),
      );
      return;
    }

    final group = _db.getGroupById(_selectedGroupId!);
    if (group == null) return;

    setState(() => _isLoading = true);

    final testId = 'test_${_uuid.v4().substring(0, 8)}';
    final test = TestModel(
      testId: testId,
      teacherId: widget.teacherId,
      groupId: group.groupId,
      groupName: group.name,
      subjectId: group.subjectId,
      subjectName: group.subjectName,
      title: title,
      imageUrl: _selectedImagePath != null
          ? _selectedImagePath!
          : (_imageUrlController.text.trim().isNotEmpty
              ? _imageUrlController.text.trim()
              : 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800&auto=format&fit=crop&q=80'),
      questionCount: _questionCount,
      correctAnswers: _correctAnswers,
      createdAt: DateTime.now(),
      active: true,
    );

    await _db.createTest(test);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.testCreatedSuccess),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groups = _db.getTeacherGroups(widget.teacherId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createTest),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: l10n.testTitle,
                hintText: l10n.testTitleHint,
                controller: _titleController,
                isRequired: true,
                errorText: _titleError,
                onChanged: (_) {
                  if (_titleError != null) setState(() => _titleError = null);
                },
              ),
              const SizedBox(height: 18),
              Text(
                l10n.selectGroup,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: AppStyles.roundedMedium,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGroupId,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                    items: groups.map((g) {
                      return DropdownMenuItem<String>(
                        value: g.groupId,
                        child: Text('${g.name} (${g.subjectName})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGroupId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.numberOfQuestions,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [5, 10, 15, 20].map((count) {
                  final isSelected = _questionCount == count;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$count ta'),
                      selected: isSelected,
                      onSelected: (_) => _onQuestionCountChanged(count),
                      selectedColor: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                      labelStyle: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.testImageUrl,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: AppStyles.roundedMedium,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: _selectedImagePath == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_library_outlined, size: 30),
                              const SizedBox(height: 8),
                              Text(
                                'Galereyadan rasm tanlang',
                                style: GoogleFonts.outfit(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: AppStyles.roundedMedium,
                          child: MediaImage(
                            imageUrl: _selectedImagePath ?? _imageUrlController.text.trim(),
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: const Center(child: Icon(Icons.photo_library_outlined, size: 30)),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.correctAnswers,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Har bir savol uchun to‘g‘ri javob variantini belgilang:',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questionCount,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) {
                  final qNum = idx + 1;
                  final currentAns = _correctAnswers[qNum] ?? 'A';

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: AppStyles.roundedSmall,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$qNum-savol:',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: ['A', 'B', 'C', 'D'].map((opt) {
                            final isSel = currentAns == opt;
                            return GestureDetector(
                              onTap: () => setState(() => _correctAnswers[qNum] = opt),
                              child: Container(
                                margin: const EdgeInsets.only(left: 6),
                                width: 36,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? (isDark ? AppColors.primaryLight : AppColors.primaryBlue)
                                      : (isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    opt,
                                    style: TextStyle(
                                      color: isSel ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: l10n.saveTest,
                isLoading: _isLoading,
                onPressed: _saveTest,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
