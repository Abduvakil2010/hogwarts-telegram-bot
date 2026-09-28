// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/hogwarts_card.dart';
import '../../core/widgets/stars_badge.dart';
import '../../data/repositories/database_repository.dart';
import '../auth/auth_provider.dart';
import '../../data/models/point_transaction_model.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final db = context.watch<DatabaseRepository>();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final group = db.getGroupById(widget.groupId);
    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.groupRating)),
        body: const Center(child: Text('Guruh topilmadi')),
      );
    }

    final students = group.studentIds.map((id) {
      final user = db.getUser(id);
      final stats = db.getStudentStats(id);
      return (user: user, stats: stats);
    }).where((e) => e.user != null).toList();

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: students.isEmpty
              ? Center(child: Text(l10n.ratingEmpty))
              : ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final entry = students[index];
                    final sUser = entry.user!;
                    final sStats = entry.stats;

                    return HogwartsCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                sUser.fullName.isNotEmpty ? sUser.fullName[0].toUpperCase() : '?',
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sUser.fullName,
                                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    StarsBadge(points: sStats.totalPoints, fontSize: 14),
                                    const SizedBox(width: 8),
                                    Text('${sStats.totalPoints}', style: GoogleFonts.outfit(fontSize: 13, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  try {
                                    await db.updateStudentPoints(
                                      teacherId: user.id,
                                      studentId: sUser.id,
                                      amount: 1,
                                      type: PointTransactionType.teacherAdd,
                                      reason: 'Teacher awarded +1',
                                    );
                                  } catch (_) {}
                                },
                                icon: const Icon(Icons.add_circle_outline, color: AppColors.successGreen),
                              ),
                              IconButton(
                                onPressed: () async {
                                  try {
                                    await db.updateStudentPoints(
                                      teacherId: user.id,
                                      studentId: sUser.id,
                                      amount: -1,
                                      type: PointTransactionType.teacherRemove,
                                      reason: 'Teacher removed -1',
                                    );
                                  } catch (_) {}
                                },
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.errorRed),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
