import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/hogwarts_card.dart';
import '../../core/widgets/stars_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../data/repositories/database_repository.dart';
import '../auth/auth_provider.dart';
import 'teacher_student_profile_dialog.dart';

class TeacherRatingScreen extends StatefulWidget {
  const TeacherRatingScreen({super.key});

  @override
  State<TeacherRatingScreen> createState() => _TeacherRatingScreenState();
}

class _TeacherRatingScreenState extends State<TeacherRatingScreen> {
  final DatabaseRepository _db = DatabaseRepository();
  String? _selectedGroupId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final groups = _db.getTeacherGroups(user.id);

    if (groups.isNotEmpty && (_selectedGroupId == null || !groups.any((g) => g.groupId == _selectedGroupId))) {
      _selectedGroupId = groups.first.groupId;
    }

    final leaderboard = _selectedGroupId != null ? _db.getGroupLeaderboard(_selectedGroupId!) : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groupRating),
      ),
      body: SafeArea(
        child: groups.isEmpty
            ? EmptyStateWidget(
                icon: Icons.groups_outlined,
                title: l10n.noGroupsTeacher,
                description: 'Reytingni ko‘rish uchun avval guruh oching va o‘quvchilarni taklif qiling.',
              )
            : Column(
                children: [
                  // Group selector chips
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: groups.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, index) {
                        final g = groups[index];
                        final isSelected = g.groupId == _selectedGroupId;

                        return ChoiceChip(
                          label: Text('${g.name} (${g.studentCount})'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedGroupId = g.groupId);
                            }
                          },
                          selectedColor: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                          labelStyle: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Leaderboard
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      child: leaderboard.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.person_search_outlined,
                              title: l10n.ratingEmpty,
                              description: 'Ushbu guruhga hali hech bir o‘quvchi a’zo bo‘lmagan.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              itemCount: leaderboard.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (ctx, index) {
                                final entry = leaderboard[index];
                                final rank = index + 1;

                                return HogwartsCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => TeacherStudentProfileDialog(
                                        student: entry.user,
                                        teacherId: user.id,
                                        onPointsChanged: () => setState(() {}),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        child: Center(
                                          child: Text(
                                            rank == 1
                                                ? '🥇'
                                                : rank == 2
                                                    ? '🥈'
                                                    : rank == 3
                                                        ? '🥉'
                                                        : '$rank',
                                            style: TextStyle(
                                              fontSize: rank <= 3 ? 22 : 15,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.user.fullName,
                                              style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Batafsil ko‘rish uchun bosing',
                                              style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StarsBadge(points: entry.totalPoints, fontSize: 16),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.chevron_right, size: 20, color: AppColors.lightTextMuted),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: (index * 50).ms);
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
