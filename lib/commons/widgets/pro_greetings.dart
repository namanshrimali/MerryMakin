import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/constants.dart';
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
      'Let\'s make today count!',
      'Adventure awaits you!',
      // 'Discover amazing events nearby',
      'Connect with amazing people today',
      'Your next adventure is waiting',
    ];

    return messages[DateTime.now().microsecond % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final greetingHeight = screenHeight * 0.13; // 40% of screen height

    return SizedBox(
      height: greetingHeight,
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [
      //       Theme.of(context).primaryColor.withOpacity(0.05),
      //       Theme.of(context).primaryColor.withOpacity(0.1),
      //       Colors.transparent,
      //     ],
      //   ),
      // ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(generalAppLevelPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              ProText(
                _getRandomMessage(),
                textStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: generalAppLevelPadding),
            ],
          ),
        ),
      ),
    );
  }
} 