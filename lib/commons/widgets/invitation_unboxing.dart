import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../models/spryly_services.dart';
import '../themes/pro_themes.dart';
import 'pro_text.dart';
import 'oauth_login.dart';
import '../../factory/app_factory.dart';

/// Party Invitation Unboxing Experience
/// An interactive welcome screen that makes login feel like opening an invitation
class InvitationUnboxing extends StatefulWidget {
  final ProThemeType themeType;
  final VoidCallback? onLoginComplete;

  const InvitationUnboxing({
    super.key,
    required this.themeType,
    this.onLoginComplete,
  });

  @override
  State<InvitationUnboxing> createState() => _InvitationUnboxingState();
}

class _InvitationUnboxingState extends State<InvitationUnboxing>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _envelopeFlyInController;
  late AnimationController _envelopeOpenController;
  late AnimationController _cardRevealController;
  late AnimationController _cardFlipController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _envelopeFlyInAnimation;
  late Animation<double> _envelopeRotationAnimation;
  late Animation<double> _envelopeScaleAnimation;
  late Animation<double> _envelopeOpenAnimation;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _pulseAnimation;

  // Confetti controllers
  late ConfettiController _trailConfettiController;
  late ConfettiController _celebrationConfettiController;

  // State
  bool _envelopeOpened = false;
  bool _cardRevealed = false;
  bool _showingLogin = false;
  double _cardScale = 1.0;
  Offset _cardOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeConfetti();
    _startEntrySequence();
  }

  void _initializeAnimations() {
    // Envelope fly-in animation (from top-right with curve)
    _envelopeFlyInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _envelopeFlyInAnimation = Tween<double>(
      begin: -200.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _envelopeFlyInController,
      curve: Curves.easeOutBack,
    ));

    _envelopeRotationAnimation = Tween<double>(
      begin: 0.15,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _envelopeFlyInController,
      curve: Curves.easeOut,
    ));

    _envelopeScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _envelopeFlyInController,
      curve: Curves.elasticOut,
    ));

    // Envelope open animation
    _envelopeOpenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _envelopeOpenAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _envelopeOpenController,
      curve: Curves.easeOutCubic,
    ));

    // Card reveal animation
    _cardRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardRevealController,
      curve: Curves.easeOutBack,
    ));

    // Card flip animation
    _cardFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardFlipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardFlipController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for tap hint
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Confetti controller
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  void _initializeConfetti() {
    _trailConfettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _celebrationConfettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  void _startEntrySequence() {
    // Start confetti trail
    _trailConfettiController.play();
    // Fly in envelope
    _envelopeFlyInController.forward();
  }

  void _handleEnvelopeTap() {
    if (_envelopeOpened) return;

    HapticFeedback.lightImpact();
    setState(() {
      _envelopeOpened = true;
    });

    _envelopeOpenController.forward().then((_) {
      // Small delay before card reveal
      Future.delayed(const Duration(milliseconds: 200), () {
        _revealCard();
      });
    });

    // Confetti burst on open
    _celebrationConfettiController.play();
  }

  void _revealCard() {
    HapticFeedback.mediumImpact();
    setState(() {
      _cardRevealed = true;
    });
    _cardRevealController.forward();
  }

  void _handleSwipeUp() {
    if (!_cardRevealed || _showingLogin) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _showingLogin = true;
    });

    // Confetti celebration
    _celebrationConfettiController.play();
    _trailConfettiController.play();

    // Flip card to show login
    _cardFlipController.forward();
  }

  void _handlePinchUpdate(ScaleUpdateDetails details) {
    if (!_cardRevealed || _showingLogin) return;

    setState(() {
      _cardScale = details.scale.clamp(1.0, 1.5);
    });
  }

  void _handlePinchEnd() {
    if (!_cardRevealed || _showingLogin) return;

    // Spring back to normal scale
    final scaleAnimation = Tween<double>(
      begin: _cardScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      )..forward(),
      curve: Curves.elasticOut,
    ));

    scaleAnimation.addListener(() {
      if (mounted) {
        setState(() {
          _cardScale = scaleAnimation.value;
        });
      }
    });
  }


  @override
  void dispose() {
    _envelopeFlyInController.dispose();
    _envelopeOpenController.dispose();
    _cardRevealController.dispose();
    _cardFlipController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    _trailConfettiController.dispose();
    _celebrationConfettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProThemes.themes[widget.themeType]!.theme;
    final screenSize = MediaQuery.sizeOf(context);
    final isSmallScreen = screenSize.height < 700;

    return Theme(
      data: theme,
      child: Stack(
        children: [
          // Confetti trail (during fly-in)
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _trailConfettiController,
              blastDirection: -math.pi / 2 - math.pi / 4, // Diagonal up-left
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),

          // Celebration confetti (on interactions)
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _celebrationConfettiController,
              blastDirection: math.pi / 2, // Upward
              maxBlastForce: 20,
              minBlastForce: 5,
              emissionFrequency: 0.02,
              numberOfParticles: 50,
              gravity: 0.3,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
                Colors.green,
              ],
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              child: GestureDetector(
                onScaleUpdate: _handlePinchUpdate,
                onScaleEnd: (_) => _handlePinchEnd(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isSmallScreen ? 40 : 60),

                    // Envelope
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _envelopeFlyInController,
                        _envelopeOpenController,
                        _pulseController,
                      ]),
                      builder: (context, child) {
                        if (_envelopeOpened && _cardRevealed) {
                          return const SizedBox.shrink();
                        }

                        final flyInOffset = _envelopeFlyInAnimation.value;
                        final rotation = _envelopeRotationAnimation.value;
                        final scale = _envelopeScaleAnimation.value *
                            (_envelopeOpened ? 0.8 : 1.0);

                        return Transform.translate(
                          offset: Offset(flyInOffset, flyInOffset * 0.5),
                          child: Transform.rotate(
                            angle: rotation,
                            child: Transform.scale(
                              scale: scale * _pulseAnimation.value,
                              child: GestureDetector(
                                onTap: _handleEnvelopeTap,
                                child: _Envelope(
                                  theme: theme,
                                  isOpen: _envelopeOpened,
                                  openProgress: _envelopeOpenAnimation.value,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Card
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _cardRevealController,
                        _cardFlipController,
                      ]),
                      builder: (context, child) {
                        if (!_cardRevealed) {
                          return const SizedBox.shrink();
                        }

                        final slideProgress = _cardSlideAnimation.value;
                        final flipProgress = _cardFlipAnimation.value;
                        final flipValue = flipProgress * math.pi;

                        return Transform.translate(
                          offset: Offset(
                            0,
                            (1 - slideProgress) * 100 + _cardOffset.dy,
                          ),
                          child: Transform.scale(
                            scale: _cardScale,
                            child: GestureDetector(
                              onVerticalDragUpdate: (details) {
                                if (details.delta.dy < -5) {
                                  // Swipe up detected
                                  _handleSwipeUp();
                                }
                              },
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001) // Perspective
                                  ..rotateY(flipValue),
                                child: _showingLogin
                                    ? _InvitationCardBack(
                                        theme: theme,
                                        onLoginComplete: widget.onLoginComplete,
                                      )
                                    : _InvitationCardFront(
                                        theme: theme,
                                        isSmallScreen: isSmallScreen,
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Swipe hint
                    if (_cardRevealed && !_showingLogin)
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: (1 - _pulseAnimation.value + 1.0) / 2,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_up,
                                    color: theme.colorScheme.primary,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  ProText(
                                    "Swipe up to RSVP",
                                    textStyle: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    SizedBox(height: isSmallScreen ? 40 : 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Envelope widget
class _Envelope extends StatelessWidget {
  final ThemeData theme;
  final bool isOpen;
  final double openProgress;

  const _Envelope({
    required this.theme,
    required this.isOpen,
    required this.openProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Envelope base
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.9),
                  theme.colorScheme.secondary.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Envelope flap (opens upward)
          Align(
            alignment: Alignment.topCenter,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(-openProgress * math.pi / 2),
              child: Container(
                width: 200,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.8),
                      theme.colorScheme.secondary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.mail_outline,
                    color: theme.colorScheme.onPrimary,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),

          // Seal/stamp
          if (openProgress < 0.5)
            Positioned(
              top: 60,
              left: 80,
              child: Opacity(
                opacity: 1 - openProgress * 2,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700), // Gold color
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Front of invitation card
class _InvitationCardFront extends StatelessWidget {
  final ThemeData theme;
  final bool isSmallScreen;

  const _InvitationCardFront({
    required this.theme,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      constraints: BoxConstraints(maxHeight: isSmallScreen ? 400 : 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            theme.colorScheme.surface.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative border
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decorative icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.celebration,
                      color: theme.colorScheme.onPrimary,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  ProText(
                    "You're Invited!",
                    textStyle: TextStyle(
                      fontSize: isSmallScreen ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontFamily: 'DancingScript',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  ProText(
                    "Join MerryMakin",
                    textStyle: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Features
                  _FeatureRow(
                    icon: Icons.event,
                    text: "Create magical celebrations",
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _FeatureRow(
                    icon: Icons.people,
                    text: "Invite friends effortlessly",
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _FeatureRow(
                    icon: Icons.calendar_today,
                    text: "Discover amazing events",
                    theme: theme,
                  ),

                  const SizedBox(height: 24),

                  // Social proof
                  ProText(
                    "Join 10,000+ party planners",
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Back of invitation card (login side)
class _InvitationCardBack extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback? onLoginComplete;

  const _InvitationCardBack({
    required this.theme,
    this.onLoginComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                ProText(
                  "Let's Get This Party Started!",
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                ProText(
                  "Sign in to start planning",
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Login buttons
                OAuthLogin(
                  userService: AppFactory().userService,
                  sprylyService: SprylyServices.MerryMakin.name,
                  onPressedCallback: onLoginComplete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Feature row widget
class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData theme;

  const _FeatureRow({
    required this.icon,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: ProText(
            text,
            textStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

