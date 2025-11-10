import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Reusable social sign-in button with consistent style
class SocialSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget icon;
  final bool loading;

  const SocialSignInButton._({
    required this.onPressed,
    required this.label,
    required this.icon,
    this.loading = false,
    super.key,
  });

  /// Factory for Google - tries SVG asset first; falls back to a text avatar
  factory SocialSignInButton.google({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
    String? googleAssetPath, // e.g. 'assets/google_logo.svg'
    Key? key,
  }) {
    Widget icon;
    if (googleAssetPath != null) {
      icon = SizedBox(
        width: 32,
        height: 32,
        child: SvgPicture.asset(
          googleAssetPath,
          fit: BoxFit.contain,
          semanticsLabel: 'Google logo',
        ),
      );
    } else {
      // fallback simple G with circle - not perfect brand but acceptable fallback
      icon = CircleAvatar(
        radius: 10,
        backgroundColor: Colors.white,
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.blue.shade700,
          ),
        ),
      );
    }
    return SocialSignInButton._(
      key: key,
      onPressed: onPressed,
      label: label,
      icon: icon,
      loading: loading,
    );
  }

  /// Factory for Apple - uses CupertinoIcons.apple_logo (vector)
  factory SocialSignInButton.apple({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
    Key? key,
  }) {
    final icon = const Icon(Icons.apple, size: 26);
    return SocialSignInButton._(
      key: key,
      onPressed: onPressed,
      label: label,
      icon: icon,
      loading: loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48, // consistent fixed height
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: loading
              ? const Row(
                  key: ValueKey('loading'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Signing in...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('normal'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    icon,
                    const SizedBox(width: 14),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
