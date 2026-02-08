import 'package:flutter_test/flutter_test.dart';
import 'package:merrymakin/commons/utils/validators.dart';

void main() {
  group('Phone Number Validation Tests', () {
    test('validatePhoneNumber returns null for valid 10-digit number', () {
      final result = validatePhoneNumber('1234567890');
      expect(result, isNull);
    });

    test('validatePhoneNumber returns null for valid number with country code', () {
      final result = validatePhoneNumber('+11234567890');
      expect(result, isNull);
    });

    test('validatePhoneNumber returns error for empty required field', () {
      final result = validatePhoneNumber(null, isRequired: true);
      expect(result, isNotNull);
      expect(result, contains('required'));
    });

    test('validatePhoneNumber returns error for too short number', () {
      final result = validatePhoneNumber('123456');
      expect(result, isNotNull);
      expect(result, contains('valid'));
    });

    test('validatePhoneNumber returns error for too long number', () {
      final result = validatePhoneNumber('1234567890123456'); // 16 digits
      expect(result, isNotNull);
    });

    test('validatePhoneNumber allows empty optional field', () {
      final result = validatePhoneNumber(null, isRequired: false);
      expect(result, isNull);
    });

    test('formatPhoneNumber formats 10-digit number correctly', () {
      final result = formatPhoneNumber('1234567890');
      expect(result, equals('(123) 456-7890'));
    });

    test('formatPhoneNumber formats 11-digit number with country code', () {
      final result = formatPhoneNumber('11234567890');
      expect(result, equals('+1 (123) 456-7890'));
    });

    test('formatPhoneNumber handles international numbers', () {
      final result = formatPhoneNumber('+441234567890');
      expect(result, contains('+44'));
    });

    test('extractCountryCode extracts code from international number', () {
      final result = extractCountryCode('+11234567890');
      expect(result, equals('+1'));
    });

    test('extractCountryCode returns null for number without country code', () {
      final result = extractCountryCode('1234567890');
      expect(result, isNull);
    });
  });
}

