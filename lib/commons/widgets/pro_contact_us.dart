import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/pro_bottom_modal_sheet.dart';
import '../widgets/pro_list_item.dart';
import '../widgets/pro_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ProContactUs extends StatelessWidget {
  final String subject =
      Platform.isIOS ? "MoneyMoney for iOS" : "MoneyMoney for Android";

  ProContactUs({super.key});
  // Define email content
  SnackBar getCouldNotOpenMailAppSnackBar(String mailAppName) {
    return SnackBar(
      content: Text('Could not open ${mailAppName}. Is it installed?'),
    );
  }

  void _openGmailAndroid(BuildContext context) async {
    String gmailUrl =
        'googlegmail:///co?subject=${subject}&body=&to=${contactUsEmail}';
    if (!await launchUrlString(gmailUrl)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(getCouldNotOpenMailAppSnackBar("Gmail App"));
    }
    Navigator.of(context).pop();
  }

  // Function to launch email client with pre-filled data
  void _sendEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: contactUsEmail, // Add recipient's email address
      queryParameters: {
        'subject': subject,
      },
    );
    if (!await canLaunchUrl(emailLaunchUri) ||
        !await launchUrl(
          emailLaunchUri,
        )) {
      ScaffoldMessenger.of(context)
          .showSnackBar(getCouldNotOpenMailAppSnackBar("System Default App"));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ProListItem(
      key: Key("Contact us"),
      title: ProText("Contact us"),
      swipeForEditAndDelete: false,
      onTap: () {
        openProBottomModalSheet(
            context,
            Column(
              children: [
                ProText(
                  "Please choose an email app",
                  textStyle: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(
                  height: generalAppLevelPadding,
                ),
                Divider(),
                ProListItem(
                  key: Key("System Default"),
                  title: ProText("System Default"),
                  swipeForEditAndDelete: false,
                  onTap: () => _sendEmail(context),
                ),
                Divider(),
                ProListItem(
                  key: Key("Gmail"),
                  title: ProText("Gmail"),
                  swipeForEditAndDelete: false,
                  onTap: () => _openGmailAndroid(context),
                ),
              ],
            ));
      },
    );
  }
}
