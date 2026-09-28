import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/hogwarts_card.dart';
import '../../core/widgets/stars_badge.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/media_image.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/database_repository.dart';
import '../auth/auth_provider.dart';
import 'student_purchases_screen.dart';

class StudentShopScreen extends StatefulWidget {
  const StudentShopScreen({super.key});

  @override
  State<StudentShopScreen> createState() => _StudentShopScreenState();
}

class _StudentShopScreenState extends State<StudentShopScreen> {
  final DatabaseRepository _db = DatabaseRepository();
  bool _isPurchasing = false;

  void _confirmAndBuy(ProductModel product, int currentPoints, String studentId, String studentName) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentPoints < product.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notEnoughPoints),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppStyles.roundedLarge),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        title: Text(
          l10n.buyButton,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.confirmPurchase(product.price),
              style: GoogleFonts.outfit(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardAlt : AppColors.primarySubtle,
                borderRadius: AppStyles.roundedSmall,
              ),
              child: Row(
                children: [
                  Text(
                    'Qoladigan ball:',
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.lightTextMuted),
                  ),
                  const Spacer(),
                  StarsBadge(points: currentPoints - product.price, fontSize: 14),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _executePurchase(product, studentId, studentName);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _executePurchase(ProductModel product, String studentId, String studentName) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isPurchasing = true);

    try {
      await _db.purchaseProduct(
        studentId: studentId,
        studentName: studentName,
        productId: product.productId,
      );

      if (mounted) {
        setState(() => _isPurchasing = false);
        _showPurchaseSuccessDialog(product);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPurchasing = false);
        final err = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err == 'not_enough_points' ? l10n.notEnoughPoints : err),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _showPurchaseSuccessDialog(ProductModel product) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppStyles.roundedLarge),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.successLight,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 48),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                l10n.purchaseSuccess,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${product.name} uchun so‘rovingiz yuborildi. Uchrashuv vaqtida o‘qituvchingizdan sovg‘angizni qabul qilib oling.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Tushundim',
                onPressed: () => Navigator.of(ctx).pop(),
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
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final points = _db.getStudentPoints(user.id);
    final products = _db.getProductsForStudent(user.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shopTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: l10n.myPurchases,
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => StudentPurchasesScreen(studentId: user.id),
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
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: Column(
            children: [
              // Balance Header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.primarySubtle,
                  borderRadius: AppStyles.roundedMedium,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.earnedPoints,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$points ⭐',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StudentPurchasesScreen(studentId: user.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: Text(
                        l10n.myPurchases,
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkCardAlt : Colors.white,
                        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Products Grid or Empty State
              Expanded(
                child: products.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.storefront_outlined,
                        title: l10n.noProductsStudent,
                        description: 'O‘qituvchingiz guruh uchun maxsus sovg‘alar qo‘shganda, ular bu yerda ko‘rinadi.',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: products.length,
                        itemBuilder: (ctx, index) {
                          final p = products[index];

                          return HogwartsCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                      child: p.imageUrl.isNotEmpty
                                          ? MediaImage(
                                              imageUrl: p.imageUrl,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              placeholder: const Center(
                                                child: Icon(Icons.card_giftcard, size: 40),
                                              ),
                                            )
                                          : const Center(
                                              child: Icon(Icons.card_giftcard, size: 40),
                                            ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      StarsBadge(points: p.price, fontSize: 14),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 36,
                                        child: ElevatedButton(
                                          onPressed: _isPurchasing
                                              ? null
                                              : () => _confirmAndBuy(p, points, user.id, user.fullName),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            l10n.buyButton,
                                            style: GoogleFonts.outfit(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: (index * 60).ms);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
