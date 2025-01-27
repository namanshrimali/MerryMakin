import 'package:url_launcher/url_launcher.dart';

class ShareUtils {
  static Future<void> shareToWhatsApp(String message, String link) async {
    final encodedMessage = Uri.encodeComponent(message);
    final encodedLink = Uri.encodeComponent(link);
    final url = Uri.parse('whatsapp://send?text=$encodedMessage $encodedLink');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  static Future<void> shareToMessages(String message, String link) async {
    final encodedText = Uri.encodeComponent('$message $link');
    final url = Uri.parse('sms:?body=$encodedText');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  static Future<void> shareViaEmail({
    required String subject,
    required String message,
    required String link,
  }) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      query: encodeQueryParameters({
        'subject': subject,
        'body': 'Hey! $message $link',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
} 