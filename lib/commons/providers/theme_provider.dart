import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/themes/pro_themes.dart';
import 'package:merrymakin/commons/widgets/pro_theme_effects.dart';

class ThemeProviderState {
  ProThemeType? proThemeType;
  ProEffectType? proEffectType;
  ThemeProviderState({this.proThemeType, this.proEffectType});
}

class ThemeNotifier extends Notifier<ThemeProviderState> {
  @override
  ThemeProviderState build() => ThemeProviderState();

  void changeTheme(ProThemeType proThemeType) {
    state = ThemeProviderState(proThemeType: proThemeType, proEffectType: state.proEffectType);
  }

  void changeEffect(ProEffectType proEffectType) {
    state = ThemeProviderState(proThemeType: state.proThemeType, proEffectType: proEffectType);
  }
}

final userProvider = NotifierProvider<ThemeNotifier, ThemeProviderState>(ThemeNotifier.new);
