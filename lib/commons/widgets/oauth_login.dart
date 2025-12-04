import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide IconAlignment;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/user_provider.dart';
import '../models/spryly_services.dart';
import '../api/google_sign_in.dart';
import '../service/user_service.dart';
import '../utils/string_utils.dart';
import 'buttons/pro_sign_in_social.dart';
import 'pro_snackbar.dart';
import '../models/user_request_dto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' hide IconAlignment;
import '../api/google_sign_in_web.dart';
import 'pro_text.dart';
// import '../api/apple_sign_in_web.dart';

class OAuthLogin extends ConsumerStatefulWidget {
  final VoidCallback? onPressedCallback;
  final UserService userService;
  final String sprylyService;
  const OAuthLogin(
      {super.key,
      this.onPressedCallback,
      required this.userService,
      required this.sprylyService});

  @override
  ConsumerState<OAuthLogin> createState() => _OAuthLoginState();
}

class _OAuthLoginState extends ConsumerState<OAuthLogin>
    with SingleTickerProviderStateMixin {
  String couldNotReachToOurServers =
      "Could not reach to our servers. You can sign in later in the app.";
  String couldNotReachAppleServer =
      "Could not reach to Apple servers. You can sign in later in the app.";
  bool _loadingApple = false;
  bool _loadingGoogle = false;
  String? _errorMessage;
  bool _showSuccess = false;
  Timer? _errorAutoDismissTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _errorAutoDismissTimer?.cancel();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _showSuccess = false;
    });
    // Auto-dismiss after 7 seconds
    _errorAutoDismissTimer?.cancel();
    _errorAutoDismissTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() => _errorMessage = null);
      }
    });
  }

  void _clearError() {
    _errorAutoDismissTimer?.cancel();
    setState(() => _errorMessage = null);
  }
  
  Future _signInWithApple() async {
    setState(() {
      _loadingApple = true;
      _errorMessage = null;
    });
    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      UserRequestDTO userRequestDTO = UserRequestDTO(
          givenName: credential.givenName,
          familyName: credential.familyName,
          email: credential.email,
          sprylyServices: SprylyServices.MerryMakin);

      widget.userService
          .addOrUpdateUser(userRequestDTO, credential.authorizationCode,
              widget.sprylyService,
              isApple: true)
          .then((user) {
        if (user != null) {
          ref.read(userProvider.notifier).login(user);
          setState(() {
            _showSuccess = true;
            _errorMessage = null;
          });
        }
        showSnackBar(
          context,
          user == null
              ? couldNotReachToOurServers
              : 'Welcome ${user.userNameForDisplay}',
        );
        if (widget.onPressedCallback != null) {
          widget.onPressedCallback!();
        }
      }).onError((error, stackTrace) {
        _showError(error.toString());
        showSnackBar(context, error.toString());
        if (widget.onPressedCallback != null) {
          widget.onPressedCallback!();
        }
      });
    } catch (e) {
      _showError(e.toString());
      showSnackBar(context, e.toString());
    } finally {
      setState(() => _loadingApple = false);
    }
  }

  Future _signInWithGoogle() async {
    setState(() {
      _loadingGoogle = true;
      _errorMessage = null;
    });
    if (kIsWeb) {
      try {
        final result = await GoogleSignInWeb.signIn();
        if (result != null) {
          UserRequestDTO userRequestDTO = UserRequestDTO(
            givenName: result.displayName,
            username: getEmailWithoutDomain(result.email),
            email: result.email,
            photoUrl: result.photoUrl,
            sprylyServices: SprylyServices.MerryMakin,
          );

          try {
            final user = await widget.userService.addOrUpdateUser(
              userRequestDTO,
              result.accessToken,
              widget.sprylyService,
            );

            if (user != null) {
              ref.read(userProvider.notifier).login(user);
              setState(() {
                _showSuccess = true;
                _errorMessage = null;
              });
            }

            showSnackBar(
              context,
              user == null
                  ? couldNotReachToOurServers
                  : 'Welcome ${user.userNameForDisplay}',
            );
            if (widget.onPressedCallback != null) {
              widget.onPressedCallback!();
            }
          } catch (error) {
            _showError(error.toString());
            showSnackBar(context, error.toString());
          }
        }
      } catch (error) {
        _showError(error.toString());
        showSnackBar(context, error.toString());
      } finally {
        setState(() => _loadingGoogle = false);
      }
    } else {
      GoogleSignInApi.signIn().then((result) {
        if (result != null) {
          result.authentication.then((googleSignInAuthentication) {
            if (googleSignInAuthentication.accessToken == null) {
              setState(() {
                _loadingGoogle = false;
              });
              _showError("No access token received from google");
              showSnackBar(context, "No access token received from google");
              return;
            }
            // family name is extracted from display name
            final familyName = result.displayName?.split(' ').last ?? '';
            final givenName = result.displayName?.split(' ').first ?? '';
            UserRequestDTO userRequestDTO = UserRequestDTO(
                givenName: givenName,
                familyName: familyName,
                username: getEmailWithoutDomain(result.email),
                email: result.email,
                photoUrl: result.photoUrl,
                sprylyServices: SprylyServices.MerryMakin);
            widget.userService
                .addOrUpdateUser(
                    userRequestDTO,
                    googleSignInAuthentication.accessToken!,
                    widget.sprylyService)
                .then((user) {
              if (user != null) {
                ref.read(userProvider.notifier).login(user);
                setState(() {
                  _showSuccess = true;
                  _errorMessage = null;
                });
              }
              showSnackBar(
                  context,
                  user == null
                      ? couldNotReachToOurServers
                      : 'Welcome ${user.userNameForDisplay}');
              if (widget.onPressedCallback != null) {
                widget.onPressedCallback!();
              }
            }).onError((error, stackTrace) {
              setState(() {
                _loadingGoogle = false;
              });
              _showError(error.toString());
              showSnackBar(context, error.toString());
              if (widget.onPressedCallback != null) {
                widget.onPressedCallback!();
              }
            });
          });
        } else {
          setState(() => _loadingGoogle = false);
        }
      }).onError((error, stackTrace) {
        setState(() {
          _loadingGoogle = false;
        });
        _showError(error.toString());
        showSnackBar(
          context,
          error.toString(),
        );
        if (widget.onPressedCallback != null) {
          widget.onPressedCallback!();
        }
      });
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://merrymakin.com/privacy_policy.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScaleFactorOf(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Fun header with app description
                Padding(
                  padding: const EdgeInsets.only(
                    top: generalAppLevelPadding,
                    bottom: generalAppLevelPadding,
                  ),
                  child: Column(
                    children: [
                      // Welcome emoji/icon
                      Semantics(
                        label: "MerryMakin celebration icon",
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.celebration,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Welcome message
                      ProText(
                        "Let's Make It Merry! 🎉",
                        textStyle: TextStyle(
                          fontSize: (28 * textScale).clamp(24.0, 32.0),
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // App description
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: generalAppLevelPadding,
                        ),
                        child: ProText(
                          "Throw epic parties, invite your crew & make memories that hit different",
                          textStyle: TextStyle(
                            fontSize: (16 * textScale).clamp(14.0, 18.0),
                            color: theme.colorScheme.onSurface.withOpacity(0.85),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Error message display - moved above buttons
                if (_errorMessage != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: generalAppLevelPadding,
                      ),
                      padding: const EdgeInsets.all(generalAppLevelPadding),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.error.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 20,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ProText(
                              _errorMessage!,
                              textStyle: TextStyle(
                                fontSize: (12 * textScale).clamp(11.0, 14.0),
                                color: theme.colorScheme.error,
                                height: 1.4,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              color: theme.colorScheme.error,
                              onPressed: _clearError,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Success message display
                if (_showSuccess) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: generalAppLevelPadding,
                    ),
                    padding: const EdgeInsets.all(generalAppLevelPadding),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ProText(
                            "Sign in successful!",
                            textStyle: TextStyle(
                              fontSize: (12 * textScale).clamp(11.0, 14.0),
                              color: Colors.green.shade700,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Privacy information - reduced visual weight
                GestureDetector(
                  onTap: _openPrivacyPolicy,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(
                        horizontal: generalAppLevelPadding,
                      ),
                      padding: const EdgeInsets.all(generalAppLevelPadding),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.verified_user,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProText(
                                  "We only collect your name, email & profile photo.",
                                  textStyle: TextStyle(
                                    fontSize: (12 * textScale).clamp(11.0, 14.0),
                                    color: theme.colorScheme.onSurface.withOpacity(0.75),
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                ProText(
                                  "Your data stays private—we never sell it.",
                                  textStyle: TextStyle(
                                    fontSize: (12 * textScale).clamp(11.0, 14.0),
                                    color: theme.colorScheme.onSurface.withOpacity(0.75),
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: generalAppLevelPadding,
                  ),
                  child: Column(
                    children: [
                      Semantics(
                        label: "Sign in with Google account",
                        button: true,
                        child: SocialSignInButton.google(
                          label: 'Sign in with Google',
                          onPressed: _signInWithGoogle,
                          loading: _loadingGoogle,
                          googleAssetPath: 'lib/commons/assets/ios_neutral_rd_na.svg',
                        ),
                      ),
                      if (!kIsWeb && Platform.isIOS) ...[
                        const SizedBox(height: 16),
                        Semantics(
                          label: "Sign in with Apple account",
                          button: true,
                          child: SocialSignInButton.apple(
                            label: 'Sign in with Apple',
                            onPressed: _signInWithApple,
                            loading: _loadingApple,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Terms and conditions
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: generalAppLevelPadding * 1.5,
                    vertical: 8,
                  ),
                  child: GestureDetector(
                    onTap: _openPrivacyPolicy,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Semantics(
                        label: "Privacy Policy link",
                        link: true,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: (13 * textScale).clamp(12.0, 15.0),
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(
                                text: "By signing in, you agree to our ",
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}
