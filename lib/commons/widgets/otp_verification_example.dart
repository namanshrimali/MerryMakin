import 'package:flutter/material.dart';
import 'pro_otp_verification.dart';

/// Example usage of the OTP verification component
/// This demonstrates how to integrate the ProOtpVerification widget
class OtpVerificationExample extends StatelessWidget {
  const OtpVerificationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ProOtpVerification(
          onVerificationSuccess: (phoneNumber) {
            // Handle successful verification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Phone number $phoneNumber verified successfully!'),
              ),
            );
            // Navigate to next screen or update user profile
          },
          onVerificationFailed: (phoneNumber) {
            // Handle failed verification
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification failed. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }
}

