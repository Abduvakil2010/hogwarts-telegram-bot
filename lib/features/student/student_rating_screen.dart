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

class StudentRatingScreen extends StatefulWidget {
  const StudentRatingScreen({super.key});

  @override
  State<StudentRatingScreen> createState() => _StudentRatingScreenState();
}

class _StudentRatingScreenState extends State<StudentRatingScreen> {
  final DatabaseRepository _db = DatabaseRepository();
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _db.refreshFromStorage();
      if (mounted) setState(() {});
    });
  }

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
    final groups = db.getStudentGroups(user.id);

    if (groups.isNotEmpty && (_selectedGroupId == null || !groups.any((g) => g.groupId == _selectedGroupId))) {
      _selectedGroupId = groups.first.groupId;
    }

    final leaderboard = _selectedGroupId != null ? db.getGroupLeaderboard(_selectedGroupId!) : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groupRating),
      ),
      body: SafeArea(
        child: groups.isEmpty
            ? EmptyStateWidget(
                icon: Icons.emoji_events_outlined,
                title: l10n.ratingEmpty,
                description: 'Reytingni ko‘rish uchun avval kamida bitta guruhga a’zo bo‘ling.',
              )
            : Column(
                children: [
                  // Group Selector Tabs
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
                          label: Text(g.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedGroupId = g.groupId);
                            }
                          },
                          labelStyle: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                          selectedColor: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Leaderboard List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      child: leaderboard.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.groups_outlined,
                              title: l10n.ratingEmpty,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              itemCount: leaderboard.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (ctx, index) {
                                final entry = leaderboard[index];
                                final rank = index + 1;
                                final isCurrentUser = entry.user.id == user.id;

                                Widget rankBadge;
                                if (rank == 1) {
                                  rankBadge = const Text('🥇', style: TextStyle(fontSize: 26));
                                } else if (rank == 2) {
                                  rankBadge = const Text('🥈', style: TextStyle(fontSize: 26));
                                } else if (rank == 3) {
                                  rankBadge = const Text('🥉', style: TextStyle(fontSize: 26));
                                } else {
                                  rankBadge = Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? AppColors.darkCardAlt : const Color(0xFFE2E8F0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$rank',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return HogwartsCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  color: isCurrentUser
                                      ? (isDark ? AppColors.darkCardAlt : AppColors.primarySubtle)
                                      : null,
                                  border: isCurrentUser
                                      ? Border.all(
                                          color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                                          width: 1.5,
                                        )
                                      : null,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 36,
                                        child: Center(child: rankBadge),
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
                                                fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                              ),
                                            ),
                                            if (isCurrentUser)
                                              Text(
                                                '(Siz)',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      StarsBadge(points: entry.totalPoints, fontSize: 16),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.05, end: 0);
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
