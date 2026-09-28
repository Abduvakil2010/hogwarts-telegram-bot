import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/stars_badge.dart';
import '../../data/models/point_transaction_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/database_repository.dart';

class TeacherStudentProfileDialog extends StatefulWidget {
  final UserModel student;
  final String teacherId;
  final VoidCallback onPointsChanged;

  const TeacherStudentProfileDialog({
    super.key,
    required this.student,
    required this.teacherId,
    required this.onPointsChanged,
  });

  @override
  State<TeacherStudentProfileDialog> createState() => _TeacherStudentProfileDialogState();
}

class _TeacherStudentProfileDialogState extends State<TeacherStudentProfileDialog> {
  final DatabaseRepository _db = DatabaseRepository();

  void _showAdjustPointsModal({required bool isAdding}) {
    final l10n = AppLocalizations.of(context);
    final amountController = TextEditingController(text: '10');
    final reasonController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAdding ? l10n.addPoints : l10n.removePoints,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isAdding ? AppColors.successGreen : AppColors.errorRed,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: l10n.pointsAmount,
                controller: amountController,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: l10n.reason,
                hintText: l10n.reasonHint,
                controller: reasonController,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: l10n.confirm,
                backgroundColor: isAdding ? AppColors.successGreen : AppColors.errorRed,
                onPressed: () async {
                  final amount = int.tryParse(amountController.text.trim()) ?? 0;
                  if (amount > 0) {
                    final finalAmount = isAdding ? amount : -amount;
                    final type = isAdding
                        ? PointTransactionType.teacherAdd
                        : PointTransactionType.teacherRemove;

                    await _db.updateStudentPoints(
                      teacherId: widget.teacherId,
                      studentId: widget.student.id,
                      amount: finalAmount,
                      type: type,
                      reason: reasonController.text.trim(),
                    );

                    widget.onPointsChanged();
                    if (mounted) setState(() {});
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = _db.getStudentStats(widget.student.id);

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
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.student.fullName[0].toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.studentProfile.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.student.fullName,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Total Points Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardAlt : const Color(0xFFFEF3C7),
                borderRadius: AppStyles.roundedMedium,
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.totalPoints,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF92400E),
                    ),
                  ),
                  StarsBadge(points: stats.totalPoints, fontSize: 18),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats grid
            Row(
              children: [
                _StatTile(
                  label: l10n.submittedTests,
                  value: '${stats.testsCount}',
                  color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                _StatTile(
                  label: l10n.correctAnswersStat,
                  value: '${stats.correctCount}',
                  color: AppColors.successGreen,
                ),
                const SizedBox(width: 8),
                _StatTile(
                  label: l10n.wrongAnswersStat,
                  value: '${stats.wrongCount}',
                  color: AppColors.errorRed,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons: + Ball qo'shish, - Ball ayirish
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAdjustPointsModal(isAdding: true),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      l10n.addPoints,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAdjustPointsModal(isAdding: false),
                    icon: const Icon(Icons.remove, size: 16),
                    label: Text(
                      l10n.removePoints,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardAlt : const Color(0xFFF8FAFC),
          borderRadius: AppStyles.roundedSmall,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
