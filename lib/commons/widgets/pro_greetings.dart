import 'package:flutter/material.dart';
import '../models/user.dart';
import './pro_text.dart';

class ProGreetings extends StatelessWidget {
  final User? user;

  const ProGreetings({
    super.key,
    this.user,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getRandomMessage() {
    final messages = [
      'Ready to make some memories?',
      'What\'s on your mind today?',
      'Time to explore something new!',
      // 'Let\'s make today count!',
      // 'Adventure awaits you!',
      // 'Discover amazing events nearby',
      'Connect with amazing people today',
      'Your next adventure is waiting',
    ];

    return messages[DateTime.now().microsecond % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    final String greeting = _getRandomMessage();

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
