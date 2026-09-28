import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/hogwarts_card.dart';
import '../../core/widgets/stars_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/media_image.dart';

import '../../data/repositories/database_repository.dart';

class StudentPurchasesScreen extends StatefulWidget {
  final String studentId;

  const StudentPurchasesScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentPurchasesScreen> createState() => _StudentPurchasesScreenState();
}

class _StudentPurchasesScreenState extends State<StudentPurchasesScreen> {
  final DatabaseRepository _db = DatabaseRepository();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final purchases = _db.getStudentPurchases(widget.studentId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myPurchases),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: purchases.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.shopping_bag_outlined,
                  title: l10n.noPurchasesStudent,
                  description: 'Do‘kondan to‘plagan ballaringiz evaziga sovg‘alar xarid qiling.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: purchases.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final item = purchases[index];
                    final isGiven = item.isGiven;

                    return HogwartsCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 60,
                              height: 60,
                              color: isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9),
                              child: MediaImage(
                                imageUrl: item.productImageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: const Icon(Icons.card_giftcard),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormatter.formatDate(item.purchasedAt),
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isGiven ? AppColors.successLight : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isGiven ? l10n.statusGiven : l10n.statusPending,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isGiven ? AppColors.successGreen : const Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StarsBadge(points: item.price, fontSize: 15),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 60).ms);
                  },
                ),
        ),
      ),
    );
  }
}
