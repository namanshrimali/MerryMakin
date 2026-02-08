import 'package:flutter/material.dart';
import 'dart:async';
import 'pro_otp_input.dart';

/// Reusable OTP verification section widget
/// Includes instruction text, OTP input fields, and resend button with countdown
class ProOtpVerificationSection extends StatefulWidget {
  final int otpLength;
  final Function(String)? onOtpCompleted;
  final Function()? onResend;
  final String? instructionText;
  final bool isLoading;
  /// When this value changes, the OTP fields are cleared. Use to reset on verification error.
  final Object? resetTrigger;

  const ProOtpVerificationSection({
    super.key,
    this.otpLength = 4,
    this.onOtpCompleted,
    this.onResend,
    this.instructionText,
    this.isLoading = false,
    this.resetTrigger,
  });

  @override
  State<ProOtpVerificationSection> createState() => _ProOtpVerificationSectionState();
}

class _ProOtpVerificationSectionState extends State<ProOtpVerificationSection> {
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _handleResend() {
    if (_resendCountdown > 0 || widget.isLoading) return;
    _startCountdown();
    widget.onResend?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.instructionText ?? 'Enter the verification code sent to your phone',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        ProOtpInput(
          onCompleted: widget.onOtpCompleted,
          length: widget.otpLength,
          resetTrigger: widget.resetTrigger,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _resendCountdown > 0 || widget.isLoading ? null : _handleResend,
          child: Text(
            _resendCountdown > 0
                ? 'Resend OTP in ${_resendCountdown}s'
                : 'Resend OTP',
          ),
        ),
      ],
    );
  }
}

