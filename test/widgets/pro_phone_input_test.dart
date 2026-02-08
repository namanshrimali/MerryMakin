import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:merrymakin/commons/widgets/pro_phone_input.dart';

void main() {
  group('ProPhoneInput Widget Tests', () {
    testWidgets('displays phone input field with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProPhoneInput(
              label: 'Phone Number',
            ),
          ),
        ),
      );

      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('validates required phone number', (WidgetTester tester) async {
      String? validationError;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProPhoneInput(
              label: 'Phone Number',
              isRequired: true,
              onValidationCallback: (error) {
                validationError = error;
              },
            ),
          ),
        ),
      );

      // Trigger validation by submitting empty field
      final textField = find.byType(TextField);
      await tester.enterText(textField, '');
      await tester.pump();

      // Validation should trigger error for empty required field
      expect(validationError, isNotNull);
    });

    testWidgets('formats phone number as user types', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProPhoneInput(),
          ),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, '1234567890');
      await tester.pump();

      // Should format as 123-456-7890
      final field = tester.widget<TextField>(textField);
      expect(field.controller?.text, contains('-'));
    });

    testWidgets('calls onChanged callback with full phone number', (WidgetTester tester) async {
      String? changedValue;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProPhoneInput(
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, '1234567890');
      await tester.pump();

      expect(changedValue, isNotNull);
      expect(changedValue, contains('+1')); // Should include country code
    });

    testWidgets('displays error message for invalid phone number', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProPhoneInput(
              isRequired: true,
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, '123'); // Too short
      await tester.pump();

      // Should show error message
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
    });
  });
}

