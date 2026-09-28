import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/repositories/database_repository.dart';

class TeacherCreateGroupDialog extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final VoidCallback onGroupCreated;

  const TeacherCreateGroupDialog({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.onGroupCreated,
  });

  @override
  State<TeacherCreateGroupDialog> createState() => _TeacherCreateGroupDialogState();
}

class _TeacherCreateGroupDialogState extends State<TeacherCreateGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final DatabaseRepository _db = DatabaseRepository();
  String? _selectedSubjectId;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final subjects = _db.getSubjects();
    if (subjects.isNotEmpty) {
      _selectedSubjectId = subjects.first.subjectId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _error = l10n.requiredField);
      return;
    }

    final subjects = _db.getSubjects();
    final subject = subjects.firstWhere(
      (s) => s.subjectId == _selectedSubjectId,
      orElse: () => subjects.first,
    );

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final group = await _db.createGroup(
        teacherId: widget.teacherId,
        teacherName: widget.teacherName,
        name: name,
        subjectId: subject.subjectId,
        subjectName: subject.name,
        description: _descController.text.trim(),
      );

      if (mounted) {
        widget.onGroupCreated();
        Navigator.of(context).pop();
        _showSuccessCodeDialog(group.groupCode, group.name);
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = l10n.serverError;
      });
    }
  }

  void _showSuccessCodeDialog(String code, String groupName) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppStyles.roundedLarge),
        title: Text(
          l10n.groupCreatedSuccess,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$groupName guruhi ochildi. Ushbu kodni o‘quvchilarga bering:',
              style: GoogleFonts.outfit(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: AppStyles.roundedMedium,
                border: Border.all(color: AppColors.primaryLight, width: 1.5),
              ),
              child: SelectableText(
                code,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjects = _db.getSubjects();

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppStyles.roundedLarge),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.createGroup,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: l10n.groupName,
              hintText: l10n.groupNameHint,
              controller: _nameController,
              isRequired: true,
              errorText: _error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectSubject,
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
                color: isDark ? AppColors.darkCardAlt : Colors.white,
                borderRadius: AppStyles.roundedMedium,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSubjectId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                  items: subjects.map((sub) {
                    return DropdownMenuItem<String>(
                      value: sub.subjectId,
                      child: Text(sub.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSubjectId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: l10n.groupDesc,
              hintText: l10n.groupDescHint,
              controller: _descController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: l10n.save,
                    isLoading: _isLoading,
                    onPressed: _createGroup,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
