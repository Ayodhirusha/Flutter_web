import 'package:flutter/material.dart';

class AppTheme {
  // Gradient Colors - Red/Black Theme
  static const Color gradientStart = Color(0xFFD32F2F); // Dark Red
  static const Color gradientMid = Color(0xFFB71C1C); // Darker Red
  static const Color gradientEnd = Color(0xFF000000); // Black

  // Additional Gradient Stops
  static const Color redLight = Color(0xFFEF5350);
  static const Color redDark = Color(0xFFC62828);
  static const Color blackLight = Color(0xFF424242);
  static const Color blackDark = Color(0xFF000000);

  // Primary Colors (Updated to Red)
  static const Color primaryColor = Color(0xFFD32F2F);
  static const Color primaryLight = Color(0xFFEF5350);
  static const Color primaryDark = Color(0xFFC62828);

  // Secondary Colors (Updated to Dark Red)
  static const Color secondaryColor = Color(0xFFB71C1C);
  static const Color secondaryLight = Color(0xFFEF5350);
  static const Color secondaryDark = Color(0xFF8B0000);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Sidebar Colors (Dark with red accent)
  static const Color sidebarBackground = Color(0xFF0D0D0D);
  static const Color sidebarItem = Color(0xFF1A1A1A);
  static const Color sidebarItemActive = Color(0xFFD32F2F);

  // Border & Divider
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFE2E8F0);

  // Gradient Decorations
  static LinearGradient get mainGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientMid, gradientEnd],
      );

  static LinearGradient get redGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [redLight, redDark],
      );

  static LinearGradient get blackGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [blackLight, blackDark],
      );

  static LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          redLight.withOpacity(0.1),
        ],
      );

  // Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: primaryColor.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: primaryColor.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get largeShadow => [
        BoxShadow(
          color: primaryColor.withOpacity(0.25),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  // Color Scheme
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: Colors.white,
    primaryContainer: primaryLight,
    onPrimaryContainer: Colors.white,
    secondary: secondaryColor,
    onSecondary: Colors.white,
    secondaryContainer: secondaryLight,
    onSecondaryContainer: Colors.white,
    tertiary: infoColor,
    onTertiary: Colors.white,
    tertiaryContainer: infoColor,
    onTertiaryContainer: Colors.white,
    error: errorColor,
    onError: Colors.white,
    errorContainer: errorColor,
    onErrorContainer: Colors.white,
    surface: surfaceColor,
    onSurface: textPrimary,
    surfaceContainerHighest: backgroundColor,
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
