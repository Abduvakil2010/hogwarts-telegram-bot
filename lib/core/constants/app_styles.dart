import 'package:flutter/material.dart';

class AppStyles {
  // Border Radii
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 28.0;

  static final BorderRadius roundedSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius roundedMedium = BorderRadius.circular(radiusMedium);
  static final BorderRadius roundedLarge = BorderRadius.circular(radiusLarge);
  static final BorderRadius roundedXLarge = BorderRadius.circular(radiusXLarge);

  // Paddings
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const EdgeInsets paddingCard = EdgeInsets.all(16);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: 24, vertical: 14);

  // Shadows
  static const List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x050F172A),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevationShadow = [
    BoxShadow(
      color: Color(0x141E3A8A),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: Color(0x2B2563EB),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];
}
