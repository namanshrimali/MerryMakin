import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

/// OTP input widget with individual digit boxes and auto-focus.
///
/// Uses Pinput (single TextField) so that soft keyboard backspace works on all
/// platforms. FocusNode.onKeyEvent does not receive events from soft keyboards.
class ProOtpInput extends StatefulWidget {
  final int length;
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final bool autofocus;
  final Color? fillColor;
  final Color? borderColor;
  final TextStyle? textStyle;
  final TextEditingController? controller;
  /// When this value changes, the OTP fields are cleared. Use to reset on verification error.
  final Object? resetTrigger;

  const ProOtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.autofocus = true,
    this.fillColor,
    this.borderColor,
    this.textStyle,
    this.controller,
    this.resetTrigger,
  });

  @override
  State<ProOtpInput> createState() => _ProOtpInputState();
}

class _ProOtpInputState extends State<ProOtpInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;
    _focusNode = FocusNode();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    }
  }

  @override
  void didUpdateWidget(covariant ProOtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetTrigger != oldWidget.resetTrigger) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fillColor = widget.fillColor ?? theme.colorScheme.surface;
    final borderColor = widget.borderColor ?? theme.colorScheme.primary;
    final textStyle = widget.textStyle ?? theme.textTheme.headlineSmall ?? const TextStyle(fontSize: 24);

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: textStyle,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: borderColor, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme;

    return Pinput(
      length: widget.length,
      controller: _controller,
      focusNode: _focusNode,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      followingPinTheme: submittedPinTheme,
      onChanged: widget.onChanged,
      onCompleted: widget.onCompleted,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      pinAnimationType: PinAnimationType.none,
    );
  }
}
