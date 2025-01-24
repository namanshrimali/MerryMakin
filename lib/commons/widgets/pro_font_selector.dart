import 'package:flutter/material.dart';

enum ProFontType {
  system,
  neonLights,  // Monoton
  partyVibes,  // Rubik Moonrocks
  elegantScript,  // Great Vibes
}

extension ProFontTypeExtension on ProFontType {
  String get displayName {
    switch (this) {
      case ProFontType.system:
        return 'Classic';
      case ProFontType.neonLights:
        return 'Neon Lights';
      case ProFontType.partyVibes:
        return 'Party Vibes';
      case ProFontType.elegantScript:
        return 'Elegant Script';
    }
  }

  String get fontFamily {
    switch (this) {
      case ProFontType.system:
        return '';
      case ProFontType.neonLights:
        return 'Monoton';
      case ProFontType.partyVibes:
        return 'RubikMoonrocks';
      case ProFontType.elegantScript:
        return 'GreatVibes';
    }
  }

  String get previewText {
    switch (this) {
      case ProFontType.system:
        return 'Classic Style';
      case ProFontType.neonLights:
        return 'NEON GLOW';
      case ProFontType.partyVibes:
        return 'Party Time!';
      case ProFontType.elegantScript:
        return 'Elegant Script';
    }
  }
}

class ProFontSelector extends StatelessWidget {
  final ProFontType selectedFont;
  final Function(ProFontType) onSelected;

  const ProFontSelector({
    Key? key,
    required this.selectedFont,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ProFontType.values.map((font) {
        return FilterChip(
          selected: selectedFont == font,
          showCheckmark: false,
          label: Text(
            font.previewText,
            style: TextStyle(
              fontFamily: font.fontFamily,
              fontSize: 16,
              color: selectedFont == font
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.primary,
          onSelected: (bool selected) {
            if (selected) {
              onSelected(font);
            }
          },
        );
      }).toList(),
    );
  }
}
