import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/repositories/database_repository.dart';

class JoinGroupDialog extends StatefulWidget {
  final String studentId;
  final VoidCallback onGroupJoined;

  const JoinGroupDialog({
    super.key,
    required this.studentId,
    required this.onGroupJoined,
  });

  @override
  State<JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends State<JoinGroupDialog> {
  final TextEditingController _codeController = TextEditingController();
  final DatabaseRepository _db = DatabaseRepository();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinGroup() async {
    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() => _error = l10n.requiredField);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _db.joinGroupByCode(studentId: widget.studentId, groupCode: code);
      if (mounted) {
        widget.onGroupJoined();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.joinGroupSuccess),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      final err = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _isLoading = false;
        if (err == 'group_not_found') {
          _error = l10n.groupNotFound;
        } else if (err == 'already_in_group') {
          _error = l10n.alreadyInGroup;
        } else {
          _error = l10n.serverError;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppStyles.roundedLarge),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.group_add_rounded, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.joinGroup,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: l10n.enterGroupCode,
              hintText: l10n.groupCodeHint,
              controller: _codeController,
              errorText: _error,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
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
                    text: l10n.join,
                    isLoading: _isLoading,
                    onPressed: _joinGroup,
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
