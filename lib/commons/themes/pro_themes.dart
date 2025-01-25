import 'package:flutter/material.dart';

enum ProThemeType {
  classic,
  romantic,
  modern,
  rustic,
  chineseNewYear,
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
    ProThemeType.modern: ProTheme(
      name: 'Modern Minimal',
      description: 'Clean lines with sage and white for contemporary style',
      theme: ThemeData(
        primaryColor: const Color(0xFF9CAF88), // Sage green
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF9CAF88),
          secondary: const Color(0xFF424242),
          surface: Colors.white,
          background: const Color(0xFFF5F5F5),
          inversePrimary: const Color(0xFFD8E2D0),
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
          primary: const Color(0xFFE53935),    // Bright red
          secondary: const Color(0xFFFFD700),   // Gold
          tertiary: const Color(0xFFFFB74D),    // Orange
          background: const Color(0xFFFFF8E1),  // Light cream
          surface: Colors.white,
          error: const Color(0xFFB71C1C),      // Dark red
        ),
      ),
    ),
  };
}
