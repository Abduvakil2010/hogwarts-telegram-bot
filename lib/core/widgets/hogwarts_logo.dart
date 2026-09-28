import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class HogwartsLogo extends StatelessWidget {
  final double size;
  final bool showSlogan;
  final Color? textColor;

  const HogwartsLogo({
    super.key,
    this.size = 56,
    this.showSlogan = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = textColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.primaryBlue);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF5D77F),
                const Color(0xFFD4AF37),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.35),
                blurRadius: size * 0.45,
                offset: Offset(0, size * 0.12),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'H',
              style: GoogleFonts.cormorantGaramond(
                fontSize: size * 0.68,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1A1A),
              ),
            ),
          ),
        ),
        SizedBox(height: size * 0.22),
        Text(
          'HOGWARTS',
          style: GoogleFonts.outfit(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            color: color,
          ),
        ),
        if (showSlogan) ...[
          const SizedBox(height: 4),
          Text(
            "O'QUV MARKAZI",
            style: GoogleFonts.outfit(
              fontSize: size * 0.18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ],
    );
  }
}
