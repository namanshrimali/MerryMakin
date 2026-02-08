import 'package:flutter/material.dart';
import 'dart:async';
import 'pro_phone_input.dart';
import 'pro_otp_input.dart';
import '../../api/otp_api.dart';
import '../../factory/app_factory.dart';

/// Complete OTP verification widget with phone input, OTP fields, and resend timer
class ProOtpVerification extends StatefulWidget {
  final Function(String)? onVerificationSuccess;
  final Function(String)? onVerificationFailed;
  final String? initialPhoneNumber;

  const ProOtpVerification({
    super.key,
    this.onVerificationSuccess,
    this.onVerificationFailed,
    this.initialPhoneNumber,
  });

  @override
  State<ProOtpVerification> createState() => _ProOtpVerificationState();
}

class _ProOtpVerificationState extends State<ProOtpVerification> {
  final OtpApi _otpApi = OtpApi(AppFactory().cookiesService);
  String? _phoneNumber;
  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;
  int _resendCountdown = 0;
  Object? _otpResetTrigger;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhoneNumber != null) {
      _phoneNumber = widget.initialPhoneNumber;
      _requestOtp();
    }
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

  Future<void> _requestOtp() async {
    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      setState(() => _errorMessage = 'Please enter a valid phone number');
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
        _startCountdown();
      } else {
        _errorMessage = 'Failed to send OTP. Please try again.';
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
    setState(() => _isLoading = false);
    if (success) {
      widget.onVerificationSuccess?.call(_phoneNumber!);
    } else {
      setState(() {
        _errorMessage = 'Invalid OTP code. Please try again.';
        _otpResetTrigger = Object();
      });
      widget.onVerificationFailed?.call(_phoneNumber!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_otpSent) ...[
          ProPhoneInput(
            initialValue: widget.initialPhoneNumber,
            label: 'Phone Number',
            hintText: '123-456-7890',
            onChanged: (phone) => setState(() {
              _phoneNumber = phone;
              _errorMessage = null;
            }),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _requestOtp,
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send OTP'),
          ),
        ] else ...[
          const Text('Enter the verification code sent to your phone', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          ProOtpInput(
            onCompleted: _verifyOtp,
            length: 6,
            resetTrigger: _otpResetTrigger,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _resendCountdown > 0 || _isLoading ? null : _requestOtp,
            child: Text(_resendCountdown > 0 ? 'Resend OTP in ${_resendCountdown}s' : 'Resend OTP'),
          ),
        ],
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)),
            child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
          ),
        ],
      ],
    );
  }
}

