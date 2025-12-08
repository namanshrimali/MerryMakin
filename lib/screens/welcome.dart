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

// Constants
class _WelcomeScreenConstants {
  static const double marqueeHeightRatio = 0.6;
  static const double brandingHeightRatio = 0.2;
  static const double arrowButtonHeightRatio = 0.2;
  static const double cardHeightRatio = 0.3;
  static const double cardWidthRatio = 0.4;
  static const double maxVerticalOffsetRatio = 0.7;
  static const double dragThresholdRatio = 0.6;
  static const double speedBase = 5.0;
  static const double speedRandomRange = 1.0;
  static const double startOffsetRandomRange = 200.0;
  static const double startOffsetSpacingRatio = 1.0 / 3.0;
  static const int eventsPerCategory = 3;
  static const int daysOffset = 7;
  static const double arrowBounceTopMargin = 12.0;
  static const double arrowBounceAmplitude = 10.0;
  static const double arrowBounceBottomMargin = 8.0;
  static const double brandingSpacing = 12.0;
  static const double cardBorderRadius = 12.0;
  static const double cardShadowOpacity = 0.2;
  static const double cardShadowBlur = 8.0;
  static const double cardShadowOffset = 2.0;
  static const double cardPadding = 12.0;
  static const double gradientOverlayOpacity = 0.6;
  static const double gradientPrimaryOpacity = 0.8;
  static const double gradientSecondaryOpacity = 0.6;
  static const double textOpacity = 0.9;
  static const double baseFontSize = 56.0;
  static const double subtitleFontSize = 24.0;
  static const double eventNameFontSize = 14.0;
  static const double eventDateFontSize = 11.0;
  static const double letterSpacingTitle = 1.2;
  static const double letterSpacingSubtitle = 0.5;
  static const int imageServicePollIntervalMs = 100;
  static const Duration arrowBounceDuration = Duration(milliseconds: 1500);
  static const Duration cardAnimationDuration = Duration(seconds: 300);
}

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
  bool _initializationScheduled = false;
  
  // Image service
  late final ImageService _imageService;
  
  // Cached data
  List<Event>? _cachedMockEvents;
  ThemeData? _cachedTheme;
  
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
      duration: _WelcomeScreenConstants.arrowBounceDuration,
    )..repeat(reverse: true);
    
    _cardController = AnimationController(
      vsync: this,
      duration: _WelcomeScreenConstants.cardAnimationDuration,
    )..repeat();
  }
  
  Future<void> _initializeCardConfigs(Size screenSize) async {
    if (_cardsInitialized) return;
    
    // Wait for ImageService to be initialized if not already
    while (!_imageService.isInitialized && mounted) {
      await Future.delayed(const Duration(milliseconds: _WelcomeScreenConstants.imageServicePollIntervalMs));
    }
    
    if (!mounted) return;
    
    final events = _getMockEvents();
    final screenWidth = screenSize.width;
    final cardHeight = screenSize.height * _WelcomeScreenConstants.cardHeightRatio;
    final cardWidth = screenSize.width * _WelcomeScreenConstants.cardWidthRatio;
    final endOffset = -cardWidth;
    final cardCount = events.length;
    final maxVerticalOffset = (screenSize.height * _WelcomeScreenConstants.maxVerticalOffsetRatio - cardHeight)
        .clamp(0.0, screenSize.height * _WelcomeScreenConstants.maxVerticalOffsetRatio);
    
    _cardConfigs = List.generate(cardCount, (i) {
      final event = events[i % events.length];
      final speedMultiplier = _WelcomeScreenConstants.speedBase + 
          _random.nextDouble() * _WelcomeScreenConstants.speedRandomRange;
      final verticalOffset = (i % 3 == 0 ? 1.0 : _random.nextDouble()) * maxVerticalOffset;
      final startOffset = i == 0 ? screenWidth - cardWidth / 2 : screenWidth + 
          (i * (screenWidth * _WelcomeScreenConstants.startOffsetSpacingRatio) + 
          _random.nextDouble() * _WelcomeScreenConstants.startOffsetRandomRange);
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
    final availableThemes = ProThemeType.values
        .where((theme) => theme != ProThemeType.classic && theme != ProThemeType.midnight)
        .toList();
    _currentTheme = availableThemes[_random.nextInt(availableThemes.length)];
    _currentEffectType = ProEffectType.values[_random.nextInt(ProEffectType.values.length)];
  }

  List<Event> _getMockEvents() {
    if (_cachedMockEvents != null) {
      return _cachedMockEvents!;
    }
    
    final now = DateTime.now();
    
    // Define event categories and their names
    const eventCategories = {
      'Christmas': ['Christmas Party', 'Holiday Celebration', 'Christmas Gathering'],
      'New Year': ['New Year\'s Eve Party', 'New Year Celebration', 'New Year Bash'],
      'Thanksgiving': ['Thanksgiving Dinner', 'Thanksgiving Gathering', 'Thanksgiving Feast'],
      'Birthday': ['Birthday Party', 'Birthday Celebration', 'Birthday Bash'],
    };
    
    final List<Event> events = [];
    
    // Create events for each category
    for (final entry in eventCategories.entries) {
      final category = entry.key;
      final names = entry.value;
      
      // Get images for this category
      final images = _imageService.getFilteredImages(category);
      
      // Create multiple events per category with different images
      for (int i = 0; i < _WelcomeScreenConstants.eventsPerCategory; i++) {
        final imageUrl = images.isNotEmpty 
            ? images[_random.nextInt(images.length)] 
            : '';
        final eventName = names[i % names.length];
        
        events.add(
          Event(
            id: 'mock_${category}_$i',
            name: eventName,
            imageUrl: imageUrl,
            startDateTime: now.add(Duration(days: _WelcomeScreenConstants.daysOffset + (i * _WelcomeScreenConstants.daysOffset))),
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
    }
    
    _cachedMockEvents = events;
    return events;
  }

  ThemeData _getCurrentTheme() {
    return _cachedTheme ??= ProThemes.themes[_currentTheme]!.theme;
  }

  void _revealLogin() {
    HapticFeedback.heavyImpact();
    final theme = _getCurrentTheme();
    openProBottomModalSheet(
      context, 
      Theme(
        data: theme,
        child: OAuthLogin(
          userService: AppFactory().userService,
          sprylyService: SprylyServices.MerryMakin.name,
        ),
      ),
      themeData: theme,
      gradientColors: [theme.colorScheme.surface],
    );
  }

  void _dismissLogin() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = _getCurrentTheme();
    final textScaler = MediaQuery.textScalerOf(context);
    
    return Theme(
      data: currentTheme,
      child: ProScaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = constraints.biggest;
            final screenHeight = screenSize.height;
            
            // Schedule initialization only once
            if (!_cardsInitialized && !_initializationScheduled) {
              _initializationScheduled = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (mounted && !_cardsInitialized) {
                  await _initializeCardConfigs(screenSize);
                }
              });
            }
            
            final textScale = textScaler.scale(_WelcomeScreenConstants.baseFontSize);
            final dragThreshold = screenHeight * _WelcomeScreenConstants.dragThresholdRatio;
            
            return ProThemeEffects(
              size: screenSize,
              themeType: _currentTheme,
              effectType: _currentEffectType,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.localPosition.dy > dragThreshold) {
                    _revealLogin();
                  }
                },
                onVerticalDragEnd: (_) {
                  _dismissLogin();
                },
                child: SizedBox(
                  height: screenHeight,
                  child: Column(
                    children: [
                      // Event Marquee
                      SizedBox(
                        height: screenHeight * _WelcomeScreenConstants.marqueeHeightRatio,
                        child: OverflowBox(
                          maxHeight: screenHeight,
                          child: RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: _cardController,
                              builder: (context, child) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    for (int i = 0; i < _cardConfigs.length; i++)
                                      _buildAnimatedCard(
                                        _cardConfigs[i],
                                        _cardController.value,
                                        screenSize,
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Branding Section
                      SizedBox(
                        height: screenHeight * _WelcomeScreenConstants.brandingHeightRatio,
                        child: Padding(
                          padding: const EdgeInsets.all(generalAppLevelPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ProText(
                                "MerryMakin",
                                textStyle: TextStyle(
                                  fontSize: textScale,
                                  fontWeight: FontWeight.w800,
                                  color: currentTheme.colorScheme.primary,
                                  letterSpacing: _WelcomeScreenConstants.letterSpacingTitle,
                                ),
                                maxLines: 1,
                                textScaler: TextScaler.noScaling,
                              ),
                              const SizedBox(height: _WelcomeScreenConstants.brandingSpacing),
                              TypingTextEffect(
                                texts: const [
                                  "A lit party may cause FOMO.",
                                  "Remember to hydrate.",
                                  "Bathroom breaks are now scheduled.",
                                  "Arrive fashionably late.",
                                  "Someone's going to spill a drink. Place your bets.",
                                  "Defend the snack table. They're not sharing.",
                                  "The bathroom line will always be longer than you expected.",
                                  "Remember to charge your phones.",
                                ],
                                textStyle: TextStyle(
                                  fontSize: _WelcomeScreenConstants.subtitleFontSize,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: _WelcomeScreenConstants.letterSpacingSubtitle,
                                  color: currentTheme.colorScheme.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Arrow Button
                      SizedBox(
                        height: screenHeight * _WelcomeScreenConstants.arrowButtonHeightRatio,
                        child: AnimatedBuilder(
                          animation: _arrowBounceController,
                          builder: (context, child) {
                            return Container(
                              margin: EdgeInsets.only(
                                top: _WelcomeScreenConstants.arrowBounceTopMargin +
                                    _arrowBounceController.value *
                                        _WelcomeScreenConstants.arrowBounceAmplitude,
                                bottom: _WelcomeScreenConstants.arrowBounceBottomMargin,
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
                ),
              ),
            );
          },
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
          height: screenSize.height * _WelcomeScreenConstants.cardHeightRatio,
          width: screenSize.width * _WelcomeScreenConstants.cardWidthRatio,
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

  Widget _buildGradientPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(_WelcomeScreenConstants.gradientPrimaryOpacity),
            theme.colorScheme.secondary.withOpacity(_WelcomeScreenConstants.gradientSecondaryOpacity),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(_WelcomeScreenConstants.cardBorderRadius);
    
    return SafeArea(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_WelcomeScreenConstants.cardShadowOpacity),
              blurRadius: _WelcomeScreenConstants.cardShadowBlur,
              offset: const Offset(0, _WelcomeScreenConstants.cardShadowOffset),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Event Image
              if (event.imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildGradientPlaceholder(context),
                  errorWidget: (context, url, error) => _buildGradientPlaceholder(context),
                )
              else
                _buildGradientPlaceholder(context),
              Container(
                padding: const EdgeInsets.all(_WelcomeScreenConstants.cardPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(_WelcomeScreenConstants.gradientOverlayOpacity),
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
                        fontSize: _WelcomeScreenConstants.eventNameFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ProText(
                      event.formattedStartDateTime,
                      textStyle: TextStyle(
                        color: Colors.white.withOpacity(_WelcomeScreenConstants.textOpacity),
                        fontSize: _WelcomeScreenConstants.eventDateFontSize,
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
