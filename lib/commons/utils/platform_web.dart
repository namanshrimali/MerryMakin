import 'dart:html' as html;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

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

void updateMetaTags(String title, String description, String imageUrl) {
    // Get the document head
    final head = html.document.head!;

    // Remove existing meta tags
    head.querySelectorAll('meta[property*="og:"], meta[name*="twitter:"]')
        .forEach((element) => element.remove());

    // Add Open Graph meta tags
    head.append(_createMetaTag('og:title', title));
    head.append(_createMetaTag('og:description', description));
    head.append(_createMetaTag('og:image', imageUrl));
    head.append(_createMetaTag('og:url', Uri.base.toString()));
    head.append(_createMetaTag('og:type', 'website'));

    // Add Twitter Card meta tags
    head.append(_createMetaTag('twitter:card', 'summary_large_image', isProperty: false));
    head.append(_createMetaTag('twitter:title', title, isProperty: false));
    head.append(_createMetaTag('twitter:description', description, isProperty: false));
    head.append(_createMetaTag('twitter:image', imageUrl, isProperty: false));
  }

  html.Element _createMetaTag(String name, String content, {bool isProperty = true}) {
    final meta = html.document.createElement('meta') as html.MetaElement;
    if (isProperty) {
      meta.setAttribute('property', name);
    } else {
      meta.setAttribute('name', name);
    }
    meta.setAttribute('content', content);
    return meta;
  }

void removeMetaTags() {
  final head = html.document.head!;
  head.querySelectorAll('meta[property*="og:"], meta[name*="twitter:"]')
      .forEach((element) => element.remove());
}
