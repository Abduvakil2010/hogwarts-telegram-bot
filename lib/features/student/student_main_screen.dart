import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import 'student_home_screen.dart';
import 'student_tests_screen.dart';
import 'student_rating_screen.dart';
import 'student_shop_screen.dart';
import '../settings/settings_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StudentHomeScreen(),
    StudentTestsScreen(),
    StudentRatingScreen(),
    StudentShopScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              selectedItemColor:
                  isDark ? AppColors.primaryLight : AppColors.primaryBlue,
              unselectedItemColor:
                  isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              selectedLabelStyle:
                  GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle:
                  GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home_rounded),
                  label: l10n.navHome,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.assignment_outlined),
                  activeIcon: const Icon(Icons.assignment_rounded),
                  label: l10n.navTests,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.leaderboard_outlined),
                  activeIcon: const Icon(Icons.leaderboard_rounded),
                  label: l10n.navRating,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.storefront_outlined),
                  activeIcon: const Icon(Icons.storefront_rounded),
                  label: l10n.navShop,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings_outlined),
                  activeIcon: const Icon(Icons.settings_rounded),
                  label: l10n.navSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
