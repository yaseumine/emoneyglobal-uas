import 'package:flutter/material.dart';

class AppColors {
  // Primary Pink
  static const Color primary = Color(0xFFE83E8C);
  static const Color primaryLight = Color(0xFFFF7AB6);
  static const Color primaryDark = Color(0xFFB91D68);
  static const Color primarySurface = Color(0xFFFFE7F1);
  static const Color primaryBorder = Color(0xFFFFB8D5);

  // Semantic
  static const Color green = Color(0xFF1DAF86);
  static const Color greenSurface = Color(0xFFE4FAF2);
  static const Color amber = Color(0xFFFFA23F);
  static const Color amberSurface = Color(0xFFFFF0D8);
  static const Color red = Color(0xFFE9365E);
  static const Color redSurface = Color(0xFFFFE7EC);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetSurface = Color(0xFFF2ECFF);

  // Neutral
  static const Color ink = Color(0xFF2A1020);
  static const Color slate600 = Color(0xFF6F405B);
  static const Color slate500 = Color(0xFF8A6478);
  static const Color slate400 = Color(0xFFBA9AAD);
  static const Color slate300 = Color(0xFFD8C2CF);
  static const Color line = Color(0xFFF2DCE8);
  static const Color line2 = Color(0xFFFFF1F7);
  static const Color bg = Color(0xFFFFF6FA);
  static const Color white = Color(0xFFFFFFFF);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
    colors: [Color(0xFFFF9CCB), primary, Color(0xFF9B165F)],
  );

  // Shadows
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: Color(0x52E83E8C),
      blurRadius: 22,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];

  // Tone map for FeatureIcon
  static Map<String, List<Color>> tones = {
    'blue': [primarySurface, primary],
    'green': [greenSurface, green],
    'amber': [amberSurface, amber],
    'red': [redSurface, red],
    'violet': [violetSurface, violet],
    'slate': [bg, slate600],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['blue']!;
}
