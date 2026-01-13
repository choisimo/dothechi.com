import 'package:flutter/material.dart';

/// 앱 디자인 시스템
/// Modern, Warm, Human-centric 디자인 철학 적용
/// Thread, Airbnb, Reddit 스타일 참고

class AppColors {
  AppColors._();

  // Primary Colors - Warm Purple/Indigo
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo-400
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600

  // Accent Colors
  static const Color accent = Color(0xFFF97316); // Orange-500
  static const Color accentLight = Color(0xFFFB923C); // Orange-400

  // Background Colors - Warm & Inviting (not pure white)
  static const Color background = Color(0xFFFAFAFA); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors - Not pure black for softer reading
  static const Color textPrimary = Color(0xFF1A1A1A); // Dark gray, not black
  static const Color textSecondary = Color(0xFF525252); // Neutral-600
  static const Color textTertiary = Color(0xFF737373); // Neutral-500
  static const Color textMuted = Color(0xFFA3A3A3); // Neutral-400

  // Semantic Colors
  static const Color success = Color(0xFF22C55E); // Green-500
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color info = Color(0xFF3B82F6); // Blue-500

  // Interactive Colors
  static const Color like = Color(0xFFEF4444); // Red for hearts
  static const Color likeBackground = Color(0xFFFEF2F2);

  // Border & Divider
  static const Color border = Color(0xFFE5E5E5);
  static const Color divider = Color(0xFFF0F0F0);

  // Category Colors
  static const Color categoryBackground = Color(0xFFEEF2FF); // Indigo-50
  static const Color categoryText = Color(0xFF4338CA); // Indigo-700

  // Tag Colors
  static const Color tagBackground = Color(0xFFF3F4F6); // Gray-100
  static const Color tagText = Color(0xFF4B5563); // Gray-600
}

class AppTypography {
  AppTypography._();

  // Font Family - Inter for web, SF Pro for iOS, Roboto for Android
  static const String fontFamily = 'Inter';

  // Display - For hero sections
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // Headings
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // Title - For card titles, section headers
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  // Body - For main content (optimized line height for readability)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.65, // Increased for better readability
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.55,
    color: AppColors.textSecondary,
  );

  // Label - For buttons, chips, metadata
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.35,
    color: AppColors.textTertiary,
  );

  // Caption - For timestamps, minor info
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.35,
    color: AppColors.textMuted,
  );
}

class AppSpacing {
  AppSpacing._();

  // Base unit: 4px
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20);

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets screenPaddingLarge =
      EdgeInsets.symmetric(horizontal: 20);
}

class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 9999;

  // Card radius
  static const BorderRadius card = BorderRadius.all(Radius.circular(16));
  static const BorderRadius cardSmall = BorderRadius.all(Radius.circular(12));

  // Chip/Tag radius
  static const BorderRadius chip = BorderRadius.all(Radius.circular(20));

  // Button radius
  static const BorderRadius button = BorderRadius.all(Radius.circular(12));

  // Avatar
  static const BorderRadius avatar = BorderRadius.all(Radius.circular(50));
}

class AppShadows {
  AppShadows._();

  // Subtle elevation for cards
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  // Elevated shadow for modals, FAB
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Soft shadow for hover states
  static const List<BoxShadow> hover = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
        color: AppColors.cardBackground,
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        labelStyle: AppTypography.labelMedium,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.tagBackground,
        labelStyle: AppTypography.labelSmall,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chip,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle:
            AppTypography.bodyMedium.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardSmall,
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
        titleTextStyle: AppTypography.headlineSmall,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
    );
  }
}
