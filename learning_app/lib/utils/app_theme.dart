import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF388E3C);
  static const Color primaryGreenLight = Color(0xFF81C784);
  static const Color accentGreen = Color(0xFF8BC34A);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);
  static const Color darkBorder = Color(0xFF404040);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textDisabled = Color(0xFF757575);

  // Status colors
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusNotStarted = Color(0xFF757575);
  static const Color statusInProgress = Color(0xFF42A5F5);
  static const Color statusCompleted = Color(0xFF66BB6A);
  static const Color statusOverdue = Color(0xFFEF5350);

  // Priority colors
  static const Color priorityLow = Color(0xFF66BB6A);
  static const Color priorityMedium = Color(0xFFFFA726);
  static const Color priorityHigh = Color(0xFFFF7043);
  static const Color priorityUrgent = Color(0xFFEF5350);

  // Design system constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationXHigh = 12.0;

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        primaryContainer: primaryGreenDark,
        secondary: accentGreen,
        secondaryContainer: primaryGreenLight,
        surface: darkSurface,
        surfaceContainer: darkCard,
        background: darkBackground,
        error: statusOverdue,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: textPrimary,
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textPrimary,
          elevation: elevationLow,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: statusOverdue),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: statusOverdue, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        hintStyle: GoogleFonts.inter(
          color: textDisabled,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: textPrimary,
        elevation: elevationMedium,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: elevationHigh,
      ),

      // List tile theme
      listTileTheme: const ListTileThemeData(
        textColor: textPrimary,
        iconColor: textSecondary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        selectedColor: primaryGreen,
        labelStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusXLarge),
        ),
      ),

      // Text theme with Google Fonts
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        displaySmall: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        headlineLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineMedium: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        headlineSmall: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleMedium: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        titleSmall: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: GoogleFonts.inter(
          color: textDisabled,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),
        labelLarge: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.inter(
          color: textDisabled,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Helper methods for status colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'inprogress':
        return statusInProgress;
      case 'completed':
        return statusCompleted;
      case 'overdue':
        return statusOverdue;
      default:
        return textSecondary;
    }
  }

  // Helper methods for priority colors
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return priorityLow;
      case 'medium':
        return priorityMedium;
      case 'high':
        return priorityHigh;
      case 'urgent':
        return priorityUrgent;
      default:
        return textSecondary;
    }
  }

  // Helper method for performance colors
  static Color getPerformanceColor(double completionRate) {
    if (completionRate >= 90) return statusCompleted;
    if (completionRate >= 70) return statusInProgress;
    if (completionRate >= 50) return statusPending;
    return statusOverdue;
  }

  // Font utility methods for consistent typography
  static TextStyle getHeadingStyle({double? fontSize, Color? color}) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? 24,
      fontWeight: FontWeight.w700,
      color: color ?? textPrimary,
      letterSpacing: 0,
    );
  }

  static TextStyle getSubheadingStyle({double? fontSize, Color? color}) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? 18,
      fontWeight: FontWeight.w600,
      color: color ?? textPrimary,
      letterSpacing: 0.15,
    );
  }

  static TextStyle getBodyStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? textPrimary,
      letterSpacing: 0.5,
      height: 1.5,
    );
  }

  static TextStyle getCaptionStyle({double? fontSize, Color? color}) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? 12,
      fontWeight: FontWeight.w400,
      color: color ?? textSecondary,
      letterSpacing: 0.4,
      height: 1.33,
    );
  }

  static TextStyle getButtonStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? textPrimary,
      letterSpacing: 0.1,
    );
  }

  static TextStyle getLabelStyle({double? fontSize, Color? color}) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? 14,
      fontWeight: FontWeight.w500,
      color: color ?? textPrimary,
      letterSpacing: 0.1,
    );
  }

  // Container decoration helpers
  static BoxDecoration getCardDecoration({Color? color, double? borderRadius}) {
    return BoxDecoration(
      color: color ?? darkCard,
      borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusMedium),
      border: Border.all(color: darkBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: primaryGreen.withOpacity(0.1),
          blurRadius: elevationMedium,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration getGradientCardDecoration({
    Color? color,
    double? borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [color ?? darkCard, (color ?? darkCard).withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusLarge),
      boxShadow: [
        BoxShadow(
          color: primaryGreen.withOpacity(0.1),
          blurRadius: elevationHigh,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration getStatusCardDecoration(
    Color statusColor, {
    double? borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius ?? borderRadiusMedium),
      border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      boxShadow: [
        BoxShadow(
          color: statusColor.withOpacity(0.1),
          blurRadius: elevationMedium,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Spacing helpers
  static EdgeInsets getScreenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width < 600
          ? spacingMedium
          : spacingLarge,
      vertical: spacingMedium,
    );
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    return EdgeInsets.all(
      MediaQuery.of(context).size.width < 600 ? spacingMedium : spacingLarge,
    );
  }

  // Animation helpers
  static Duration getShortAnimationDuration() =>
      const Duration(milliseconds: 200);
  static Duration getMediumAnimationDuration() =>
      const Duration(milliseconds: 300);
  static Duration getLongAnimationDuration() =>
      const Duration(milliseconds: 500);
}
