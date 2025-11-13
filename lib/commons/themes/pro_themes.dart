import 'package:flutter/material.dart';

enum ProThemeType {
  classic,
  romantic,
  rustic,
  chineseNewYear,
  autumn,
  christmasWinter,
  midnight,
}

class ProTheme {
  final String name;
  final ThemeData theme;
  final String description;

  ProTheme({
    required this.name,
    required this.theme,
    required this.description,
  });
}

class ProThemes {
  static final Map<ProThemeType, ProTheme> themes = {
    ProThemeType.classic: ProTheme(
      name: 'Classic',
      description: 'Default Material Design theme',
      theme: ThemeData(
        primaryColor: Colors.blue, // Material default blue
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blue[700]!,
          surface: Colors.white,
          background: Colors.grey[50]!,
          inversePrimary: Colors.blue[100]!,
          tertiary: Colors.blue[50]!,
        ),
        useMaterial3: true, // Use Material 3 design
      ),
    ),
    ProThemeType.romantic: ProTheme(
      name: 'Romantic Blush',
      description: 'Soft pinks and roses for a dreamy atmosphere',
      theme: ThemeData(
        primaryColor: const Color(0xFFE8B4B8), // Soft pink
        colorScheme: ColorScheme.light(
          primary: const Color(0xFFE8B4B8),
          secondary: const Color(0xFF6D4C41),
          surface: Colors.white,
          background: const Color(0xFFFCF7F8),
          inversePrimary: const Color(0xFFF4DFDF),
        ),
      ),
    ),
    ProThemeType.christmasWinter: ProTheme(
      name: 'Christmas Winter',
      description:
          'A festive and cozy atmosphere with wintery whites, greens, and reds.',
      theme: ThemeData(
        primaryColor: const Color(0xFF9B1D20), // Classic Christmas Red
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF9B1D20), // Christmas Red
          secondary: const Color(0xFF006747), // Evergreen/Christmas Green
          surface: const Color(0xFFFFFFFF), // Snowy White
          background: const Color(0xFFF2F8FC), // Soft winter sky blue
          inversePrimary:
              const Color(0xFFFFF5E1), // Warm, festive cream (for contrast)
        ),
      ),
    ),
    ProThemeType.autumn: ProTheme(
      name: 'Autumn Harvest',
      description: 'A cozy, earthy vibe inspired by fall foliage.',
      theme: ThemeData(
        primaryColor: const Color(0xFFB85C43), // Warm, earthy orange
        colorScheme: ColorScheme.light(
          primary: const Color(0xFFB85C43), // Warm, earthy orange
          secondary: const Color(0xFF7F4F24), // Deep brown
          surface: const Color(0xFFFAEBD7), // Soft beige (like fallen leaves)
          background: const Color(0xFFF8E4D4), // Light autumn gold
          inversePrimary:
              const Color(0xFFF2C8A3), // Light gold/cream for contrast
        ),
      ),
    ),
    ProThemeType.rustic: ProTheme(
      name: 'Rustic Charm',
      description: 'Earthy tones for a natural, countryside feel',
      theme: ThemeData(
        primaryColor: const Color(0xFF8D6E63), // Warm brown
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF8D6E63),
          secondary: const Color(0xFF5D4037),
          surface: const Color(0xFFF5F5F5),
          background: const Color(0xFFFAF3E8),
          inversePrimary: const Color(0xFFD7CCC8),
        ),
      ),
    ),
    ProThemeType.chineseNewYear: ProTheme(
      name: 'Festive Red',
      description: 'Traditional red and gold celebration',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFE53935), // Bright red
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          primary: const Color(0xFFE53935), // Bright red
          secondary: const Color(0xFFFFD700), // Gold
          tertiary: const Color(0xFFFFB74D), // Orange
          background: const Color(0xFFFFF8E1), // Light cream
          surface: Colors.white,
          error: const Color(0xFFB71C1C), // Dark red
        ),
      ),
    ),
    ProThemeType.midnight: ProTheme(
      name: 'Midnight Glow',
      description: 'A sleek dark theme with luminous highlights.',
      theme: _buildMidnightTheme(),
    ),
  };

  static ThemeData _buildMidnightTheme() {
    const background = Color(0xFF121212);
    const surface = Color(0xFF1E1E1E);
    const canvas = Color(0xFF0F0F0F);
    const secondary = Color(0xFF64B5F6);
    const tertiary = Color(0xFFBB86FC);
    const inversePrimary = Color(0xFF1E88E5);

    const colorScheme = ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Color(0xFF121212),
      secondary: secondary,
      onSecondary: Color(0xFF0D1015),
      surface: surface,
      onSurface: Colors.white,
      background: background,
      onBackground: Colors.white,
      tertiary: tertiary,
      onTertiary: Color(0xFF0D1015),
      inversePrimary: inversePrimary,
      error: Color(0xFFCF6679),
      onError: Colors.black,
    );

    final baseDark = ThemeData(
      useMaterial3: true,
      // brightness: Brightness.dark,
      primaryColor: colorScheme.primary,
      focusColor: Colors.white,
      scaffoldBackgroundColor: background,
      canvasColor: canvas,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: ThemeData(
        useMaterial3: true,
        // brightness: Brightness.dark,
      ).textTheme.apply(
            bodyColor: colorScheme.onBackground,
            displayColor: colorScheme.onBackground,
          ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.45),
        margin: const EdgeInsets.all(16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: canvas,
        foregroundColor: colorScheme.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      chipTheme: ChipThemeData.fromDefaults(
        // brightness: Brightness.dark,
        primaryColor: colorScheme.primary,
        secondaryColor: secondary,
        labelStyle: TextStyle(color: colorScheme.onSurface),
      ).copyWith(
        selectedColor: colorScheme.primary,
        secondarySelectedColor: secondary,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
        ),
      ),
      dividerColor: colorScheme.onSurface.withOpacity(0.12),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: secondary),
      iconTheme: IconThemeData(color: colorScheme.primary),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.87),
          fontSize: 16,
        ),
      ),
    );

    return baseDark.copyWith(
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
        actionTextColor: colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
