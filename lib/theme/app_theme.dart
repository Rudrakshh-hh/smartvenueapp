import 'package:flutter/material.dart';

class AppTheme {
  // Dark Cyber Theme Colors
  static const Color darkBg = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF121826);
  static const Color darkCard = Color(0xFF1A233A);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Soft Eye-Friendly White Theme Colors (No Flash Bang Glare)
  static const Color lightBg = Color(0xFFEAEFF5);
  static const Color lightSurface = Color(0xFFF8FAFD);
  static const Color lightCard = Color(0xFFE2E8F0);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF1E293B);
  static const Color lightTextMuted = Color(0xFF475569);

  // Common Vibrant Neon Accents (Dark Mode)
  static const Color cyanPrimary = Color(0xFF00D8F6);
  static const Color purpleAccent = Color(0xFF9333EA);
  static const Color blueGlow = Color(0xFF2563EB);
  static const Color emeraldSuccess = Color(0xFF059669);
  static const Color amberWarning = Color(0xFFD97706);
  static const Color roseAlert = Color(0xFFE11D48);

  // High-Contrast Deep Vibrant Accent Colors for Light Theme Headings & Highlights
  static Color cyan(bool isDark) =>
      isDark ? cyanPrimary : const Color(0xFF0369A1); // Deep Ocean Cobalt Cyan
  static Color purple(bool isDark) =>
      isDark ? purpleAccent : const Color(0xFF6B21A8); // Deep Royal Violet
  static Color blue(bool isDark) =>
      isDark ? blueGlow : const Color(0xFF1E40AF); // Deep Sapphire Blue
  static Color emerald(bool isDark) =>
      isDark ? emeraldSuccess : const Color(0xFF065F46); // Deep Forest Emerald
  static Color amber(bool isDark) =>
      isDark ? amberWarning : const Color(0xFF92400E); // Deep Warm Amber
  static Color rose(bool isDark) =>
      isDark ? roseAlert : const Color(0xFF9F1239); // Deep Crimson

  // Backwards Compatible Direct Accessors
  static const Color bgDark = darkBg;
  static const Color bgSurface = darkSurface;
  static const Color bgCard = darkCard;
  static const Color textPrimaryConst = darkTextPrimary;
  static const Color textSecondaryConst = darkTextSecondary;
  static const Color textMutedConst = darkTextMuted;

  // Dynamic Theme Helpers
  static Color getBgDark(bool isDark) => isDark ? darkBg : lightBg;
  static Color getBgSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color getBgCard(bool isDark) => isDark ? darkCard : lightCard;

  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color textMuted(bool isDark) =>
      isDark ? darkTextMuted : lightTextMuted;

  // Dark Theme Definition
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBg,
      primaryColor: cyanPrimary,
      colorScheme: const ColorScheme.dark(
        primary: cyanPrimary,
        secondary: purpleAccent,
        surface: darkSurface,
        error: roseAlert,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: cyanPrimary,
        unselectedItemColor: darkTextMuted,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: darkCard.withValues(alpha: 0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: cyanPrimary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface.withValues(alpha: 0.8),
        hintStyle: const TextStyle(color: darkTextMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cyanPrimary.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cyanPrimary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cyanPrimary, width: 1.5),
        ),
      ),
    );
  }

  // White / Light Theme Definition
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: lightBg,
      primaryColor: const Color(0xFF0369A1),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0369A1),
        secondary: Color(0xFF6B21A8),
        surface: lightSurface,
        error: Color(0xFF9F1239),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: Color(0xFF0369A1),
        unselectedItemColor: lightTextMuted,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: lightSurface.withValues(alpha: 0.95),
        elevation: 3,
        shadowColor: const Color(0xFF0369A1).withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF0369A1).withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        hintStyle: const TextStyle(color: lightTextMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF0369A1).withValues(alpha: 0.35),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF0369A1).withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0369A1), width: 1.8),
        ),
      ),
    );
  }

  // Dynamic Glass Card Box Decoration
  static BoxDecoration glassDecoration({
    required bool isDark,
    double borderRadius = 20.0,
    Color? borderColor,
    List<Color>? gradientColors,
  }) {
    final defaultBorder = isDark
        ? cyanPrimary.withValues(alpha: 0.2)
        : const Color(0xFF0369A1).withValues(alpha: 0.35);

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            gradientColors ??
            [
              (isDark ? darkSurface : lightSurface).withValues(
                alpha: isDark ? 0.85 : 0.95,
              ),
              (isDark ? darkCard : lightCard).withValues(
                alpha: isDark ? 0.6 : 0.9,
              ),
            ],
      ),
      border: Border.all(
        color: borderColor ?? defaultBorder,
        width: isDark ? 1.2 : 1.4,
      ),
      boxShadow: [
        BoxShadow(
          color:
              (borderColor ?? (isDark ? cyanPrimary : const Color(0xFF0369A1)))
                  .withValues(alpha: isDark ? 0.08 : 0.12),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Dynamic Neon Glowing Box Decoration
  static BoxDecoration neonGlowDecoration({
    Color color = cyanPrimary,
    double borderRadius = 16.0,
    bool isDark = true,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: color.withValues(alpha: isDark ? 0.15 : 0.12),
      border: Border.all(color: color, width: isDark ? 1.5 : 1.6),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: isDark ? 0.35 : 0.18),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
