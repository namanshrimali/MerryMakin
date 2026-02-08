import 'package:flutter/material.dart';
import 'pro_text_field.dart';

/// Phone number input widget with country code support and validation
class ProPhoneInput extends StatefulWidget {
  final String? initialValue;
  final String? label;
  final String? hintText;
  final Function(String)? onChanged;
  final Function(String)? onValidationCallback;
  final TextEditingController? controller;
  final bool autofocus;
  final double? width;
  final bool isRequired;

  const ProPhoneInput({
    super.key,
    this.initialValue,
    this.label,
    this.hintText,
    this.onChanged,
    this.onValidationCallback,
    this.controller,
    this.autofocus = false,
    this.width,
    this.isRequired = true,
  });

  @override
  State<ProPhoneInput> createState() => _ProPhoneInputState();
}

class _ProPhoneInputState extends State<ProPhoneInput> {
  late TextEditingController _controller;
  String _countryCode = '+1';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
      return 'Phone number is required';
    }
    if (value != null && value.trim().isNotEmpty) {
      final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length < 10) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  String _formatPhoneNumber(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length <= 3) return digitsOnly;
    if (digitsOnly.length <= 6) {
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    }
    final maxLen = digitsOnly.length > 10 ? 10 : digitsOnly.length;
    return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6, maxLen)}';
  }

  void _onPhoneChanged(String value) {
    final formatted = _formatPhoneNumber(value);
    if (_controller.text != formatted) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    final fullNumber = '$_countryCode${value.replaceAll(RegExp(r'[^\d]'), '')}';
    final error = _validatePhoneNumber(value);
    setState(() => _errorMessage = error);
    widget.onChanged?.call(fullNumber);
    if (error != null) widget.onValidationCallback?.call(error);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Text(_countryCode, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ProTextField(
                textEditingController: _controller,
                label: widget.label ?? 'Phone Number',
                hintText: widget.hintText ?? '123-456-7890',
                keyboardType: TextInputType.phone,
                autofocus: widget.autofocus,
                width: widget.width,
                onChanged: _onPhoneChanged,
                onValidationCallback: _validatePhoneNumber,
                prefixWidget: const Icon(Icons.phone),
              ),
            ),
          ],
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
          ),
      ],
    );
  }
}

