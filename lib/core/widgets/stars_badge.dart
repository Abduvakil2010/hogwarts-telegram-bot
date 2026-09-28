import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class StarsBadge extends StatelessWidget {
  final int points;
  final double fontSize;
  final bool isLarge;
  final VoidCallback? onTap;

  const StarsBadge({
    super.key,
    required this.points,
    this.fontSize = 15,
    this.isLarge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLarge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppStyles.roundedLarge,
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.starGold.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⭐',
              style: TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 10),
            Text(
              '$points',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF92400E),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: AppStyles.roundedSmall,
          border: Border.all(color: const Color(0xFFFCD34D), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              '$points',
              style: GoogleFonts.outfit(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF92400E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
