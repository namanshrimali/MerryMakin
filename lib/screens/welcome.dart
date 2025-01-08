import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/spryly_services.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/oauth_login.dart';
import 'package:merrymakin/factory/app_factory.dart';

class MerryMakinWelcomeScreen extends StatefulWidget {

  const MerryMakinWelcomeScreen(
      {super.key,});

  @override
  State<MerryMakinWelcomeScreen> createState() =>
      _MerryMakinWelcomeScreenState();
}

class _MerryMakinWelcomeScreenState extends State<MerryMakinWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    Widget navigationButtonsAtBottom = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          OAuthLogin(
              userService: AppFactory().userService, sprylyService: SprylyServices.MerryMakin.name,
            ),
        ],
      ),
    );

    return Scaffold(
      body: const Padding(
        padding: EdgeInsets.only(
            left: generalAppLevelPadding / 2,
            right: generalAppLevelPadding / 2),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ProText("Welcome to Merry Makin",
              textStyle: TextStyle(fontSize: 72, fontWeight: FontWeight.w200)),
        ]),
      ),
      bottomNavigationBar: navigationButtonsAtBottom,
    );
  }
}
