String? validateTextField(
    String? text, String label, int minLength, int maxLength, {bool isRequired = true}) {
  // final double _enteredAmount = double.parse(_amountController.text);
  if (isRequired && (text == null ||
      text.trim().isEmpty ||
      text.trim().length <= minLength ||
      text.trim().length > maxLength)) {
    return '${label} must be between ${minLength} and ${maxLength} characters';
  }
  return null;
}

String? validateEmailField(String? value, {bool isRequired = true}) {
  if (isRequired && (value == null || value.trim().isEmpty)) {
    return 'Please enter an email';
  }
  // Regular expression to validate the email format
  final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (value != null &&
      value.trim().isNotEmpty &&
      !emailRegex.hasMatch(value.trim())) {
    return 'Please enter a valid email address';
  }
  return null; // null means no error
}

/// Validates a phone number string
/// Accepts phone numbers with or without country code
/// Returns null if valid, error message if invalid
String? validatePhoneNumber(String? value, {bool isRequired = true}) {
  if (isRequired && (value == null || value.trim().isEmpty)) {
    return 'Phone number is required';
  }
  
  if (value != null && value.trim().isNotEmpty) {
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check minimum length (10 digits for US numbers, 7-15 for international)
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number (10-15 digits)';
    }
    
    // Basic format validation - should start with country code or area code
    if (digitsOnly.length == 10) {
      // US format: should not start with 0 or 1
      if (digitsOnly[0] == '0' || digitsOnly[0] == '1') {
        return 'Please enter a valid phone number';
      }
    }
  }
  
  return null; // null means no error
}

/// Formats a phone number for display
/// Returns formatted string like: +1 (123) 456-7890
String formatPhoneNumber(String phoneNumber) {
  final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  
  if (digitsOnly.length == 10) {
    return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
  } else if (digitsOnly.length == 11 && digitsOnly[0] == '1') {
    return '+1 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
  } else if (digitsOnly.length > 10) {
    // International format
    return '+$digitsOnly';
  }
  
  return phoneNumber; // Return as-is if can't format
}

/// Extracts country code from phone number
/// Returns country code (e.g., "+1") or null if not found
String? extractCountryCode(String phoneNumber) {
  if (phoneNumber.startsWith('+')) {
    final match = RegExp(r'^\+\d{1,3}').firstMatch(phoneNumber);
    return match?.group(0);
  }
  return null;
}
