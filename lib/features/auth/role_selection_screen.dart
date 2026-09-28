import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/hogwarts_logo.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/user_model.dart';
import 'auth_provider.dart';
import 'telegram_id_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const HogwartsLogo(size: 60),
                      const SizedBox(height: 32),
                      Text(
                        l10n.selectRole,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.appSlogan,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: 36),

                      _RoleCard(
                        title: l10n.student,
                        subtitle: 'Guruhlarga qo‘shiling, testlar ishlang, ball yig‘ing va do‘kondan sovg‘alar oling.',
                        icon: Icons.school_rounded,
                        isSelected: auth.selectedRole == UserRole.student,
                        onTap: () => auth.setSelectedRole(UserRole.student),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 16),

                      _RoleCard(
                        title: l10n.teacher,
                        subtitle: 'Guruhlar oching, testlar yuklang, o‘quvchilarni baholang va maxsus sovg‘alar qo‘shing.',
                        icon: Icons.psychology_rounded,
                        isSelected: auth.selectedRole == UserRole.teacher,
                        onTap: () => auth.setSelectedRole(UserRole.teacher),
                      ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

                      const Spacer(),

                      CustomButton(
                        text: l10n.next,
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const TelegramIdScreen(),
                              transitionsBuilder: (_, a, __, c) => SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
                                child: c,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.primaryLight : AppColors.primaryBlue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkCardAlt : AppColors.primarySubtle)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: AppStyles.roundedLarge,
          border: Border.all(
            color: isSelected ? activeColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: isSelected ? AppStyles.glowShadow : (isDark ? [] : AppStyles.lightShadow),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? activeColor : (isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9)),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? activeColor
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: 2,
                ),
                color: isSelected ? activeColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
