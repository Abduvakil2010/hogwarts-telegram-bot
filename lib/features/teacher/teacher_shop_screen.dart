import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/hogwarts_card.dart';
import '../../core/widgets/stars_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/media_image.dart';
import '../../data/repositories/database_repository.dart';
import '../auth/auth_provider.dart';
import 'teacher_create_product_dialog.dart';
import 'teacher_orders_screen.dart';

class TeacherShopScreen extends StatefulWidget {
  const TeacherShopScreen({super.key});

  @override
  State<TeacherShopScreen> createState() => _TeacherShopScreenState();
}

class _TeacherShopScreenState extends State<TeacherShopScreen> {
  final DatabaseRepository _db = DatabaseRepository();

  void _openCreateProductDialog(String teacherId, String teacherName) {
    showDialog(
      context: context,
      builder: (ctx) => TeacherCreateProductDialog(
        teacherId: teacherId,
        teacherName: teacherName,
        onProductCreated: () => setState(() {}),
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

    final products = _db.getProductsForTeacher(user.id);
    final orders = _db.getTeacherOrders(user.id);
    final pendingOrdersCount = orders.where((o) => o.isPending).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shopTitle),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined),
                tooltip: l10n.allOrders,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TeacherOrdersScreen(teacherId: user.id),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),
              if (pendingOrdersCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        '$pendingOrdersCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'teacher_shop_create_product',
        onPressed: () => _openCreateProductDialog(user.id, user.fullName),
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          l10n.addProduct,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: Column(
            children: [
              // Orders quick link banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      Icons.inventory_2_outlined,
                      color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'O‘quvchilar xaridlari: ${orders.length} ta ($pendingOrdersCount ta kutilmoqda)',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TeacherOrdersScreen(teacherId: user.id),
                          ),
                        ).then((_) => setState(() {}));
                      },
                      child: Text(
                        l10n.allOrders,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Products Grid
              Expanded(
                child: products.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.storefront_outlined,
                        title: l10n.noProductsTeacher,
                        description: 'O‘quvchilaringiz ball yig‘ib sotib olishlari uchun rag‘batlantiruvchi sovg‘alar qo‘shing.',
                        actionText: l10n.addProduct,
                        onAction: () => _openCreateProductDialog(user.id, user.fullName),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.76,
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          StarsBadge(points: p.price, fontSize: 14),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              p.groupIds.contains('all') ? 'Barcha' : 'Tanlangan',
                                              style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                              ),
                                            ),
                                          ),
                                        ],
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
