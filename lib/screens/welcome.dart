import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/spryly_services.dart';
import 'package:merrymakin/commons/themes/pro_themes.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/pro_scaffold.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_theme_effects.dart';
import 'package:merrymakin/commons/widgets/oauth_login.dart';
import 'package:merrymakin/factory/app_factory.dart';

class MerryMakinWelcomeScreen extends StatefulWidget {
  const MerryMakinWelcomeScreen({
    super.key,
  });
  @override
  State<MerryMakinWelcomeScreen> createState() => _MerryMakinWelcomeScreenState();
}

class _MerryMakinWelcomeScreenState extends State<MerryMakinWelcomeScreen> {
  Timer? _themeTimer;
  late ProThemeType _currentTheme;
  late ProEffectType _currentEffectType;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeRandomTheme();
    _startThemeTimer();
  }

  @override
  void dispose() {
    _themeTimer?.cancel();
    super.dispose();
  }

  void _initializeRandomTheme() {
    _currentTheme = ProThemeType.values.where((theme) => theme != ProThemeType.classic).toList()[_random.nextInt(ProThemeType.values.length - 1)];
    _currentEffectType = ProEffectType.values[_random.nextInt(ProEffectType.values.length)];
  }

  void _startThemeTimer() {
    _themeTimer = Timer.periodic(const Duration(seconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _currentTheme = ProThemeType.values.where((theme) => theme != ProThemeType.classic).toList()[_random.nextInt(ProThemeType.values.length - 1)];
          _currentEffectType = ProEffectType.values[_random.nextInt(ProEffectType.values.length)];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ProThemes.themes[_currentTheme]!.theme;

    return ProThemeEffects(
      size: MediaQuery.sizeOf(context),
      themeType: _currentTheme,
      effectType: _currentEffectType,
      child: Theme(
        data: currentTheme,
        child: ProScaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: generalAppLevelPadding / 2,
                right: generalAppLevelPadding / 2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  ProText(
                    "Merry",
                    textStyle: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w200,
                      color: currentTheme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    textScaler: TextScaler.noScaling,
                  ),
                  ProText(
                    "Makin",
                    textStyle: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w200,
                      color: currentTheme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    textScaler: TextScaler.noScaling,
                  ),
                  const Spacer(),
                  OAuthLogin(
                    userService: AppFactory().userService,
                    sprylyService: SprylyServices.MerryMakin.name,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
