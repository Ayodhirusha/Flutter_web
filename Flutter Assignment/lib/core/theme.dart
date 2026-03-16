import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Professional Crimson & Slate
  static const Color primaryColor = Color(0xFFDC2626); // Crimson Red
  static const Color primaryLight = Color(0xFFEF4444);
  static const Color primaryDark = Color(0xFF991B1B);

  static const Color secondaryColor = Color(0xFF1E293B); // Dark Slate
  static const Color accentColor = Color(0xFFF59E0B); // Amber

  // Backgrounds
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF0EA5E9);

  // Sidebar Colors - Deep Crimson/Slate
  static const Color sidebarBackground = Color(0xFF0F172A);
  static const Color sidebarItem = Color(0xFF1E293B);
  static const Color sidebarItemActive = Color(0xFFDC2626);

  // Border & Divider
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFE2E8F0);

  // Gradients
  static LinearGradient get mainGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, primaryDark],
      );

  static LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [secondaryColor, secondaryColor.withOpacity(0.8)],
      );

  static LinearGradient get glassGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.8),
          Colors.white.withOpacity(0.4),
        ],
      );

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      );

  // Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF991B1B).withOpacity(0.03),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: const Color(0xFF991B1B).withOpacity(0.05),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get largeShadow => [
        BoxShadow(
          color: const Color(0xFF64748B).withOpacity(0.16),
          blurRadius: 48,
          offset: const Offset(0, 16),
        ),
      ];

  // Color Scheme
  static final lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: Colors.white,
    primaryContainer: primaryLight,
    onPrimaryContainer: Colors.white,
    secondary: secondaryColor,
    onSecondary: Colors.white,
    secondaryContainer: primaryLight.withOpacity(0.1),
    onSecondaryContainer: primaryDark,
    tertiary: infoColor,
    onTertiary: Colors.white,
    tertiaryContainer: infoColor.withOpacity(0.1),
    onTertiaryContainer: infoColor,
    error: errorColor,
    onError: Colors.white,
    errorContainer: errorColor.withOpacity(0.1),
    onErrorContainer: errorColor,
    surface: surfaceColor,
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,
    outline: borderColor,
    shadow: Colors.black,
    inverseSurface: textPrimary,
    onInverseSurface: Colors.white,
    inversePrimary: primaryLight,
  );

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2xl = 48;

  // Border Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;
}
