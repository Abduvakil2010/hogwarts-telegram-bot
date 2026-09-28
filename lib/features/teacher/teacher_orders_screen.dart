import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/hogwarts_card.dart';
import '../../core/widgets/stars_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../data/repositories/database_repository.dart';

class TeacherOrdersScreen extends StatefulWidget {
  final String teacherId;

  const TeacherOrdersScreen({
    super.key,
    required this.teacherId,
  });

  @override
  State<TeacherOrdersScreen> createState() => _TeacherOrdersScreenState();
}

class _TeacherOrdersScreenState extends State<TeacherOrdersScreen> {
  final DatabaseRepository _db = DatabaseRepository();

  Future<void> _markAsGiven(String purchaseId) async {
    final l10n = AppLocalizations.of(context);
    await _db.markPurchaseDelivered(purchaseId);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.markedGivenSuccess),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = _db.getTeacherOrders(widget.teacherId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.allOrders),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: orders.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.inventory_2_outlined,
                  title: l10n.noOrdersTeacher,
                  description: 'O‘quvchilar do‘kondan sovg‘alar xarid qilganda, bu yerda buyurtmalar ro‘yxati ko‘rinadi.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final order = orders[index];
                    final isGiven = order.isGiven;

                    return HogwartsCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? AppColors.darkCardAlt : AppColors.primarySubtle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.studentName,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${l10n.purchasedDate}: ${DateFormatter.formatDate(order.purchasedAt)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StarsBadge(points: order.price, fontSize: 15),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            height: 1,
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.card_giftcard, size: 18, color: AppColors.primaryLight),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        order.productName,
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (isGiven)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check, size: 14, color: AppColors.successGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.statusGiven,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.successGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ElevatedButton(
                                  onPressed: () => _markAsGiven(order.purchaseId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.successGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    l10n.markAsGiven,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
