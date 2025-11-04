import 'package:flutter/material.dart';
import '../models/user.dart';
import './pro_text.dart';

class ProGreetings extends StatelessWidget {
  final User? user;

  const ProGreetings({
    super.key,
    this.user,
  });

  String _getMessageForDay() {
    final weekDayMessages = [
      'New week, let’s do this! 💪',
      'Getting closer to the weekend!',
      'Hump day vibes! 🐪',
      'Almost there! One more day! ⏳',
      'You made it! TGIF!',
      'Saturday’s here, let’s shine! ✨',
      'Sundays are for recharging! ☀️',
    ];
    return weekDayMessages[(DateTime.now().weekday - 1) % weekDayMessages.length];
  }

  @override
  Widget build(BuildContext context) {
    final String greeting = _getMessageForDay();

    return ProText(
      greeting,
      textStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        // height: 1.2,
        color: Theme.of(context).primaryColor,
      ),
      maxLines: 2,
    );
  }
}
