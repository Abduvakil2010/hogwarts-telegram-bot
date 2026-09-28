import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/hogwarts_card.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/media_image.dart';
import '../../data/repositories/database_repository.dart';
import '../auth/auth_provider.dart';
import 'student_test_solve_screen.dart';

class StudentTestsScreen extends StatefulWidget {
  const StudentTestsScreen({super.key});

  @override
  State<StudentTestsScreen> createState() => _StudentTestsScreenState();
}

class _StudentTestsScreenState extends State<StudentTestsScreen> {
  final DatabaseRepository _db = DatabaseRepository();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final db = context.watch<DatabaseRepository>();
    final tests = db.getTestsForStudent(user.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navTests),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: tests.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.assignment_outlined,
                  title: l10n.noTestsStudent,
                  description: 'O‘qituvchingiz guruh uchun yangi test yaratganda, u shu yerda paydo bo‘ladi.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: tests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (ctx, index) {
                    final test = tests[index];
                    final isSubmitted = _db.hasStudentSubmittedTest(test.testId, user.id);
                    final result = isSubmitted ? _db.getTestResult(test.testId, user.id) : null;

                    return HogwartsCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (test.imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              child: Container(
                                height: 140,
                                width: double.infinity,
                                color: isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9),
                                child: MediaImage(
                                  imageUrl: test.imageUrl,
                                  width: double.infinity,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  placeholder: Container(
                                    height: 140,
                                    color: isDark ? AppColors.darkCardAlt : AppColors.primarySubtle,
                                    child: Center(
                                      child: Icon(
                                        Icons.quiz_rounded,
                                        size: 48,
                                        color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.darkBorder : AppColors.primarySubtle,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        test.groupName,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      l10n.questionsCount(test.questionCount),
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  test.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (isSubmitted)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.successLight,
                                      borderRadius: AppStyles.roundedSmall,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: AppColors.successGreen, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              l10n.testCompleted,
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.successGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (result != null)
                                          Text(
                                            '${result.correctCount}/${test.questionCount} (+${result.earnedPoints} ⭐)',
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF065F46),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                else
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) => StudentTestSolveScreen(
                                              test: test,
                                              studentId: user.id,
                                              studentName: user.fullName,
                                            ),
                                            transitionsBuilder: (_, a, __, c) => SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(1, 0),
                                                end: Offset.zero,
                                              ).animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
                                              child: c,
                                            ),
                                          ),
                                        ).then((_) => setState(() {}));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Text(
                                        l10n.startTest,
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 80).ms);
                  },
                ),
        ),
      ),
    );
  }
}
