import 'package:url_launcher/url_launcher.dart';

Future<void> openInAppleMaps(String address, void Function(String) showSnackBar) async {
  final encodedLocation = Uri.encodeComponent(address);
  final Uri nativeUrl =
      Uri.parse('maps://maps.apple.com/?q=$encodedLocation');
  final Uri webUrl = Uri.parse('http://maps.apple.com/?q=$encodedLocation');

  if (await canLaunchUrl(nativeUrl)) {
    await launchUrl(nativeUrl, mode: LaunchMode.externalApplication);
  } else if (await canLaunchUrl(webUrl)) {
    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  } else {
    showSnackBar('Could not open Apple Maps');
  }
}

Future<void> openInGoogleMaps(String address, void Function(String) showSnackBar) async {
  final encodedLocation = Uri.encodeComponent(address);
  final Uri nativeUrl = Uri.parse('comgooglemaps://?q=$encodedLocation');
  final Uri webUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedLocation');

  if (await canLaunchUrl(nativeUrl)) {
    await launchUrl(nativeUrl, mode: LaunchMode.externalApplication);
  } else if (await canLaunchUrl(webUrl)) {
    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  } else {
    showSnackBar('Could not open Google Maps');
  }
}
