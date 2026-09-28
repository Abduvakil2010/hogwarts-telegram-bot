import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/media_image.dart';
import '../../data/models/test_model.dart';
import '../../data/models/test_result_model.dart';
import '../../data/repositories/database_repository.dart';

class StudentTestSolveScreen extends StatefulWidget {
  final TestModel test;
  final String studentId;
  final String studentName;

  const StudentTestSolveScreen({
    super.key,
    required this.test,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentTestSolveScreen> createState() => _StudentTestSolveScreenState();
}

class _StudentTestSolveScreenState extends State<StudentTestSolveScreen> {
  final DatabaseRepository _db = DatabaseRepository();
  final Map<int, String> _selectedAnswers = {};
  bool _isSubmitting = false;

  void _onOptionSelected(int questionNum, String option) {
    setState(() {
      _selectedAnswers[questionNum] = option;
    });
  }

  void _confirmAndSubmit() {
    final l10n = AppLocalizations.of(context);
    final totalQ = widget.test.questionCount;
    final answeredQ = _selectedAnswers.length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppStyles.roundedLarge),
        title: Text(
          l10n.submitTest,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          answeredQ < totalQ
              ? 'Siz $totalQ ta savoldan faqat $answeredQ tasiga javob berdingiz. Testni yuborasizmi?'
              : l10n.confirmSubmitTest,
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _submitTest();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest() async {
    setState(() => _isSubmitting = true);

    try {
      final result = await _db.submitTest(
        testId: widget.test.testId,
        studentId: widget.studentId,
        studentName: widget.studentName,
        studentAnswers: _selectedAnswers,
      );

      if (mounted) {
        _showResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        final err = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err == 'already_taken_test' ? 'Siz bu testni topshirgansiz' : err),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _showResultDialog(TestResultModel result) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppStyles.roundedLarge),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFEF3C7),
                ),
                child: const Center(
                  child: Text('⭐', style: TextStyle(fontSize: 40)),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
              Text(
                l10n.testResultTitle,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.scoreRatio(result.correctCount, widget.test.questionCount),
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: AppStyles.roundedSmall,
                ),
                child: Text(
                  l10n.pointsEarned(result.earnedPoints),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.resultDialogDesc,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 28),
              CustomButton(
                text: l10n.backToTests,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
              ),
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
    final totalQ = widget.test.questionCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Test Details Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.primarySubtle,
                        borderRadius: AppStyles.roundedMedium,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.test.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.test.groupName} • ${l10n.questionsCount(totalQ)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Test Image (if any)
                    if (widget.test.imageUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: AppStyles.roundedMedium,
                        child: Container(
                          width: double.infinity,
                          color: isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9),
                          child: MediaImage(
                            imageUrl: widget.test.imageUrl,
                            width: double.infinity,
                            height: 280,
                            fit: BoxFit.contain,
                            placeholder: Container(
                              height: 180,
                              color: isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 40,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Test savollari namunasi',
                                      style: GoogleFonts.outfit(fontSize: 14, color: AppColors.lightTextMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Text(
                      l10n.enterAnswers,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Har bir savol uchun to‘g‘ri javob variantini tanlang:',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Questions & Option Selectors (1 to totalQ)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalQ,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final qNum = index + 1;
                        final currentChoice = _selectedAnswers[qNum];

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: AppStyles.roundedMedium,
                            border: Border.all(
                              color: currentChoice != null
                                  ? (isDark ? AppColors.primaryLight : AppColors.primaryBlue)
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              width: currentChoice != null ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currentChoice != null
                                      ? (isDark ? AppColors.primaryLight : AppColors.primaryBlue)
                                      : (isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9)),
                                ),
                                child: Center(
                                  child: Text(
                                    '$qNum',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: currentChoice != null
                                          ? Colors.white
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Options: A, B, C, D
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: ['A', 'B', 'C', 'D'].map((opt) {
                                    final isSelected = currentChoice == opt;
                                    return GestureDetector(
                                      onTap: () => _onOptionSelected(qNum, opt),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        width: 44,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (isDark ? AppColors.primaryLight : AppColors.primaryBlue)
                                              : (isDark ? AppColors.darkCardAlt : const Color(0xFFF8FAFC)),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected
                                                ? (isDark ? AppColors.primaryLight : AppColors.primaryBlue)
                                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                            width: isSelected ? 1.8 : 1.0,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            opt,
                                            style: GoogleFonts.outfit(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Submit Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: CustomButton(
                text: l10n.submitTest,
                isLoading: _isSubmitting,
                onPressed: _confirmAndSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
