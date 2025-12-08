import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/spryly_services.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/service/image_service.dart';
import 'package:merrymakin/commons/themes/pro_themes.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_icon_button.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:merrymakin/commons/widgets/pro_scaffold.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_theme_effects.dart';
import 'package:merrymakin/commons/widgets/oauth_login.dart';
import 'package:merrymakin/commons/widgets/typing_text_effect.dart';
import 'package:merrymakin/factory/app_factory.dart';

class MerryMakinWelcomeScreen extends StatefulWidget {
  const MerryMakinWelcomeScreen({super.key});

  @override
  State<MerryMakinWelcomeScreen> createState() => _MerryMakinWelcomeScreenState();
}

class _MerryMakinWelcomeScreenState extends State<MerryMakinWelcomeScreen>
    with TickerProviderStateMixin {
  late ProThemeType _currentTheme;
  late ProEffectType _currentEffectType;
  final Random _random = Random();
  
  // Animation controllers
  late AnimationController _arrowBounceController;
  late AnimationController _cardController;
  
  // Card configurations
  List<_CardConfig> _cardConfigs = [];
  bool _cardsInitialized = false;
  
  // Image service
  late final ImageService _imageService;

  @override
  void initState() {
    super.initState();
    _imageService = AppFactory().imageService;
    _initializeRandomTheme();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    
    _arrowBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 300),
    )..repeat();
  }
  
  Future<void> _initializeCardConfigs(Size screenSize) async {
    if (_cardsInitialized) return;
    
    // Wait for ImageService to be initialized if not already
    while (!_imageService.isInitialized && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    if (!mounted) return;
    
    final events = _getMockEvents();
    final screenWidth = screenSize.width;
    final cardHeight = screenSize.height * 0.3;
    final cardWidth = screenSize.width * 0.4;
    final endOffset = -cardWidth;
    final cardCount = events.length;
    
    _cardConfigs = List.generate(cardCount, (i) {
      final event = events[i % events.length];
      final speedMultiplier = 5 + _random.nextDouble();
      final maxVerticalOffset = (screenSize.height * 0.7 - cardHeight).clamp(0.0, screenSize.height * 0.7);
      final verticalOffset = (i % 3 == 0 ? 1 : _random.nextDouble()) * maxVerticalOffset;
      final startOffset = screenWidth + (i == 0 ? 0 : (i * (screenWidth / 3)) + _random.nextDouble() * 200.0);
      final totalDistance = startOffset - endOffset;
      
      return _CardConfig(
        event: event,
        startOffset: startOffset,
        verticalOffset: verticalOffset,
        speed: speedMultiplier,
        totalDistance: totalDistance,
      );
    });
    
    if (mounted) {
      setState(() {
        _cardsInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _arrowBounceController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _initializeRandomTheme() {
    _currentTheme = ProThemeType.midnight;
    _currentTheme = ProThemeType.values
        .where((theme) => theme != ProThemeType.classic && theme != ProThemeType.midnight)
        .toList()[_random.nextInt(ProThemeType.values.length - 2)];
    _currentEffectType = ProEffectType.values[_random.nextInt(ProEffectType.values.length)];
  }

  List<Event> _getMockEvents() {
    final now = DateTime.now();
    final random = Random();
    
    // Define event categories and their names
    final eventCategories = {
      'Christmas': ['Christmas Party', 'Holiday Celebration', 'Christmas Gathering'],
      'New Year': ['New Year\'s Eve Party', 'New Year Celebration', 'New Year Bash'],
      'Thanksgiving': ['Thanksgiving Dinner', 'Thanksgiving Gathering', 'Thanksgiving Feast'],
      'Birthday': ['Birthday Party', 'Birthday Celebration', 'Birthday Bash'],
    };
    
    List<Event> events = [];
    
    // Create events for each category
    eventCategories.forEach((category, names) {
      // Get images for this category
      final images = _imageService.getFilteredImages(category);
      
      // Create multiple events per category with different images
      for (int i = 0; i < 3; i++) {
        final imageUrl = images.isNotEmpty 
            ? images[random.nextInt(images.length)] 
            : '';
        final eventName = names[i % names.length];
        
        events.add(
          Event(
            id: 'mock_${category}_$i',
            name: eventName,
            imageUrl: imageUrl,
            startDateTime: now.add(Duration(days: 7 + (i * 7))),
            hosts: [
              User(
                email: 'host_${category}_$i@example.com',
                firstRegistered: now,
                timeStampWhenAuthorized: now,
              )
            ],
            createdAt: now,
            updatedAt: now,
            location: 'Event Venue',
          ),
        );
      }
    });
    
    return events;
  }

  void _revealLogin() {
    HapticFeedback.heavyImpact();
    openProBottomModalSheet(
      context, 
      Theme(data: ProThemes.themes[_currentTheme]!.theme, child: OAuthLogin(userService: AppFactory().userService, sprylyService: SprylyServices.MerryMakin.name)),
      themeData: ProThemes.themes[_currentTheme]!.theme,
      gradientColors: [
        ProThemes.themes[_currentTheme]!.theme.colorScheme.surface,
        // ProThemes.themes[_currentTheme]!.theme.colorScheme.secondary,
      ],
    );
    // _revealController.forward();
  }

  void _dismissLogin() {
    HapticFeedback.lightImpact();
    // _revealController.reverse();
  }

  // void _handleDragUpdate(DragUpdateDetails details) {
  //   if (_revealController.value >= 0.4) return;
    
  //   final screenHeight = MediaQuery.sizeOf(context).height;
  //   final dragDelta = -details.delta.dy / (screenHeight * 0.6);
  //   final newValue = (_revealController.value + dragDelta).clamp(0.0, 0.4);
    
  //   // Haptic feedback at thresholds
  //   final thresholds = [0.1, 0.2, 0.3];
  //   for (final threshold in thresholds) {
  //     if (newValue >= threshold && _lastHapticThreshold < threshold) {
  //       HapticFeedback.mediumImpact();
  //       _lastHapticThreshold = threshold;
  //       break;
  //     }
  //   }
    
  //   _revealController.value = newValue;
  // }

  // void _handleDragEnd(DragEndDetails details) {
  //   if (_revealController.value >= 0.25) {
  //     HapticFeedback.heavyImpact();
  //     _revealLogin();
  //   } else {
  //     _dismissLogin();
  //   }
  //   _lastHapticThreshold = -1.0;
  // }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ProThemes.themes[_currentTheme]!.theme;
    final screenSize = MediaQuery.sizeOf(context);
    final double textScale = MediaQuery.textScalerOf(context).scale(56);
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.localPosition.dy > screenSize.height * 0.6) {
          _revealLogin();
        }
      },
      onVerticalDragEnd: (details) {
        if (details.localPosition.dy > screenSize.height * 0.6) {
          _dismissLogin();
        }
      },
      child: ProThemeEffects(
        size: screenSize,
        themeType: _currentTheme,
        effectType: _currentEffectType,
        child: Theme(
          data: currentTheme,
          child: ProScaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (!_cardsInitialized) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (mounted) {
                      await _initializeCardConfigs(screenSize);
                    }
                  });
                }              
                // Capture variables for use in AnimatedBuilder
                final theme = currentTheme;
                final size = screenSize;
                
                return SizedBox(
                  height: size.height,
                  child: Column(
                    children: [
                      // Event Marquee
                      SizedBox(
                        height: size.height * 0.6,
                        child: OverflowBox(
                          maxHeight: size.height,
                          child: RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: _cardController,
                              builder: (context, child) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    for (int i = 0; i < _cardConfigs.length; i++)
                                      _buildAnimatedCard(_cardConfigs[i], _cardController.value, size),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Branding Section
                      SizedBox(
                        height: size.height * 0.2,
                        child: Padding(
                          padding: const EdgeInsets.all(generalAppLevelPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // font size should be responsive and scale with the screen size
                              ProText(
                                "MerryMakin",
                                textStyle: TextStyle(
                                  fontSize: textScale,
                                  // fontFamily: 'Pacifico',
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 1.2,
                                ),
                                maxLines: 1,
                                textScaler: TextScaler.noScaling,
                              ),
                              const SizedBox(height: 12),
                              TypingTextEffect(
                                texts: ["A lit party may cause FOMO.", "Remember to hydrate.", 
                                 "Bathroom breaks are now scheduled.", "Arrive fashionably late.", "Someone’s going to spill a drink. Place your bets.", "Defend the snack table. They’re not sharing.",  "The bathroom line will always be longer than you expected.", "Remember to charge your phones."],
                                textStyle: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  // fontFamily: 'DancingScript',
                                  letterSpacing: 0.5,
                                  color: theme.colorScheme.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              // ProText(
                              //   "Design Your Perfect Party!",
                              //   textStyle: TextStyle(
                              //     fontSize: 24,
                              //     fontWeight: FontWeight.w800,
                              //     fontFamily: 'DancingScript',
                              //     letterSpacing: 0.5,
                              //     color: theme.colorScheme.primary,
                              //   ),
                              //   maxLines: 1,
                              //   textScaler: TextScaler.noScaling,
                              // ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Arrow Button
                        SizedBox(
                          height: size.height * 0.2,
                          child: AnimatedBuilder(
                            animation: _arrowBounceController,
                            builder: (context, child) {
                              return Container(
                                margin: EdgeInsets.only(
                                  top: 12 + _arrowBounceController.value * 10,
                                  bottom: 8,
                                ),
                                child: ProIconButton(
                                  icon: Icons.keyboard_arrow_up,
                                  size: 48,
                                  onPressed: _revealLogin,
                                  label: "Swipe up to continue",
                                  
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAnimatedCard(_CardConfig config, double masterProgress, Size screenSize) {
    final cardProgress = (masterProgress * config.speed) % 1.0;
    final xPosition = config.getXPosition(cardProgress);
    
    return Positioned(
      top: config.verticalOffset,
      left: xPosition,
      child: RepaintBoundary(
        child: _WelcomeEventCard(
          event: config.event,
          height: screenSize.height * 0.3,
          width: screenSize.width * 0.4,
        ),
      ),
    );
  }
}

class _CardConfig {
  final Event event;
  final double startOffset;
  final double verticalOffset;
  final double speed;
  final double totalDistance;
  
  const _CardConfig({
    required this.event,
    required this.startOffset,
    required this.verticalOffset,
    required this.speed,
    required this.totalDistance,
  });
  
  double getXPosition(double animationProgress) {
    return startOffset - (animationProgress * totalDistance);
  }
}

class _WelcomeEventCard extends StatelessWidget {
  final Event event;
  final double height;
  final double width;

  const _WelcomeEventCard({
    required this.event,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Event Image
              if (event.imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ProText(
                      event.name,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ProText(
                      event.formattedStartDateTime,
                      textStyle: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
