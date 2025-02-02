import 'dart:html' as html;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

bool isIOS() {
  final userAgent = html.window.navigator.userAgent.toLowerCase();
  return userAgent.contains('iphone') || 
         userAgent.contains('ipad') || 
         userAgent.contains('ipod') ||
         (userAgent.contains('mac') && html.window.navigator.maxTouchPoints! > 0); // For iPadOS
}

void setUrlStrategyForPlatform() {
  setUrlStrategy(PathUrlStrategy());
}

