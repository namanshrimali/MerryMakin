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
