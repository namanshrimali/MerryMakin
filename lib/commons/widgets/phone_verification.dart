import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/user_provider.dart';
import '../service/user_service.dart';
import 'pro_snackbar.dart';
import 'pro_text.dart';
import 'pro_phone_input.dart';
import 'pro_otp_verification_section.dart';
import '../../api/otp_api.dart';
import '../../factory/app_factory.dart';

class PhoneVerification extends ConsumerStatefulWidget {
  final VoidCallback? onVerificationSuccess;
  final UserService userService;
  final String sprylyService;

  const PhoneVerification({
    super.key,
    this.onVerificationSuccess,
    required this.userService,
    required this.sprylyService,
  });

  @override
  ConsumerState<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends ConsumerState<PhoneVerification>
    with SingleTickerProviderStateMixin {
  final OtpApi _otpApi = OtpApi(AppFactory().cookiesService);
  String? _phoneNumber;
  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;
  bool _showSuccess = false;
  Object? _otpResetTrigger;
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
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _errorAutoDismissTimer?.cancel();
    super.dispose();
  }

  bool get _isUserLoggedIn {
    final userState = ref.watch(userProvider);
    return userState.user != null;
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _showSuccess = false;
    });
    _errorAutoDismissTimer?.cancel();
    _errorAutoDismissTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  void _clearError() {
    _errorAutoDismissTimer?.cancel();
    setState(() => _errorMessage = null);
  }

  Future<void> _requestOtp() async {
    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      _showError('Please enter a valid phone number');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final success = await _otpApi.requestOtp(_phoneNumber!);
    setState(() {
      _isLoading = false;
      if (success) {
        _otpSent = true;
      } else {
        _showError('Failed to send OTP. Please try again.');
      }
    });
  }

  Future<void> _verifyOtp(String otpCode) async {
    if (_phoneNumber == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final success = await _otpApi.verifyOtp(_phoneNumber!, otpCode);
    setState(() {
      _isLoading = false;
      if (success) {
        _showSuccess = true;
        widget.onVerificationSuccess?.call();
        showSnackBar(context, 'Phone number verified successfully!');
      } else {
        _otpResetTrigger = Object();
        _showError('Invalid OTP code. Please try again.');
      }
    });
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://merrymakin.com/privacy_policy.html');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, double textScale) {
    return Padding(
      padding: const EdgeInsets.only(
        top: generalAppLevelPadding,
        bottom: generalAppLevelPadding,
      ),
      child: Column(
        children: [
          Semantics(
            label: "MerryMakin phone verification icon",
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isUserLoggedIn ? Icons.phone_android : Icons.celebration,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ProText(
            _isUserLoggedIn
                ? "Add Your Phone Number 📱"
                : "Let's Make It Merry! 🎉",
            textStyle: TextStyle(
              fontSize: (28 * textScale).clamp(24.0, 32.0),
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
            child: ProText(
              _isUserLoggedIn
                  ? "Stay updated on your events with instant notifications"
                  : "Throw epic parties, invite your crew & make memories that hit different",
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
    );
  }

  Widget _buildPrivacyAssurance(
      BuildContext context, ThemeData theme, double textScale) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
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
                    _isUserLoggedIn
                        ? "We only use your phone number for event updates."
                        : "We only collect your phone number for event notifications.",
                    textStyle: TextStyle(
                      fontSize: (12 * textScale).clamp(11.0, 14.0),
                      color: theme.colorScheme.onSurface.withOpacity(0.75),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ProText(
                    _isUserLoggedIn
                        ? "Your data stays private—we never sell it."
                        : "No spam, no marketing—just event updates. Your data stays private—we never sell it.",
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
    );
  }

  Widget _buildErrorMessage(
      BuildContext context, ThemeData theme, double textScale) {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
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
            Icon(Icons.error_outline, size: 20, color: theme.colorScheme.error),
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
    );
  }

  Widget _buildSuccessMessage(
      BuildContext context, ThemeData theme, double textScale) {
    if (!_showSuccess) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
      padding: const EdgeInsets.all(generalAppLevelPadding),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 20, color: Colors.green.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: ProText(
              "Phone number verified successfully!",
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
    );
  }

  Widget _buildPhoneInputSection() {
    if (_otpSent) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
        child: ProOtpVerificationSection(
          otpLength: 4,
          onOtpCompleted: _verifyOtp,
          onResend: _requestOtp,
          isLoading: _isLoading,
          resetTrigger: _otpResetTrigger,
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
          child: ProPhoneInput(
            label: 'Phone Number',
            hintText: '123-456-7890',
            onChanged: (phone) => setState(() {
              _phoneNumber = phone;
              _errorMessage = null;
            }),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _requestOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send Code',
                      style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
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
                _buildHeader(context, theme, textScale),
                const SizedBox(height: 16),
                _buildErrorMessage(context, theme, textScale),
                if (_errorMessage != null) const SizedBox(height: 16),
                _buildSuccessMessage(context, theme, textScale),
                if (_showSuccess) const SizedBox(height: 16),
                if (!_otpSent) ...[
                  _buildPrivacyAssurance(context, theme, textScale),
                  const SizedBox(height: 24),
                ],
                _buildPhoneInputSection(),
                // _buildOAuthSection(),
                const SizedBox(height: 24),
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
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(
                                  text:
                                      "By clicking 'send code', you agree to our "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(
                                  text:
                                      " and consent to receive event texts from MerryMakin and hosts. Msg frequency varies; data rates may apply."),
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
