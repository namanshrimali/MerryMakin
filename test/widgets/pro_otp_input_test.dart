import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:merrymakin/commons/widgets/pro_otp_input.dart';
import 'package:pinput/pinput.dart';

void main() {
  group('ProOtpInput Widget Tests', () {
    testWidgets('displays Pinput (single field, receives all input including soft keyboard)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProOtpInput(length: 6),
          ),
        ),
      );

      expect(find.byType(Pinput), findsOneWidget);
    });

    testWidgets('enters multiple digits in sequence', (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProOtpInput(
              length: 6,
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Pinput));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '12');
      await tester.pump();

      expect(controller.text, equals('12'));
    });

    testWidgets('calls onChanged callback when OTP changes', (WidgetTester tester) async {
      String? currentOtp;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProOtpInput(
              length: 6,
              onChanged: (otp) {
                currentOtp = otp;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Pinput));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '1');
      await tester.pump();

      expect(currentOtp, equals('1'));
    });

    testWidgets('calls onCompleted when all fields are filled', (WidgetTester tester) async {
      String? completedOtp;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProOtpInput(
              length: 6,
              onCompleted: (otp) {
                completedOtp = otp;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Pinput));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '012345');
      await tester.pump();

      expect(completedOtp, equals('012345'));
    });

    testWidgets('backspace deletes last digit', (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProOtpInput(length: 6, controller: controller),
          ),
        ),
      );

      await tester.tap(find.byType(Pinput));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '12');
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(controller.text, equals('1'));
    });

    testWidgets('backspace on empty field leaves field empty', (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProOtpInput(length: 6, controller: controller),
          ),
        ),
      );

      await tester.tap(find.byType(Pinput));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(controller.text, isEmpty);
    });

    testWidgets('resetTrigger clears fields when value changes', (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      Object trigger1 = Object();
      Object trigger2 = Object();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProOtpInput(
              length: 6,
              controller: controller,
              resetTrigger: trigger1,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Pinput));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '123');
      await tester.pump();
      expect(controller.text, equals('123'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProOtpInput(
              length: 6,
              controller: controller,
              resetTrigger: trigger2,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(controller.text, isEmpty);
    });

    testWidgets('only accepts digits in input fields', (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProOtpInput(length: 6, controller: controller),
          ),
        ),
      );

      await tester.tap(find.byType(Pinput));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'abc123');
      await tester.pump();

      expect(controller.text, isNot(contains('a')));
    });
  });
}
