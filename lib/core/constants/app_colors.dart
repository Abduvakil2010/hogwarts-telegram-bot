import 'package:flutter/material.dart';

/// HOGWARTS Design System Colors
/// Modern Educational Theme: White + Sapphire & Royal Blue
/// with Golden Star Accents and Dark Navy Night Mode
class AppColors {
  // Brand Primary Blues
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep Royal Sapphire
  static const Color primaryLight = Color(0xFF2563EB); // Vibrant Electric Blue
  static const Color primaryDark = Color(0xFF172554); // Dark Navy
  static const Color primarySubtle = Color(0xFFEFF6FF); // Soft blue tint for cards

  // Secondary & Accents
  static const Color accentCyan = Color(0xFF0284C7);
  static const Color starGold = Color(0xFFF59E0B); // Amber / Gold for Stars ⭐
  static const Color starGoldLight = Color(0xFFFEF3C7);
  static const Color successGreen = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warningOrange = Color(0xFFF97316);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Light Theme Neutrals
  static const Color lightBg = Color(0xFFF8FAFC); // Clean slate tint
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardAlt = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark Theme Neutrals
  static const Color darkBg = Color(0xFF0A0F1D); // Deep Midnight
  static const Color darkCard = Color(0xFF121B2F);
  static const Color darkCardAlt = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF27354E);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient starGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
