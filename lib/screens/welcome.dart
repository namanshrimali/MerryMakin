import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/spryly_services.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/oauth_login.dart';
import 'package:merrymakin/factory/app_factory.dart';

class MerryMakinWelcomeScreen extends StatefulWidget {
  const MerryMakinWelcomeScreen({
    super.key,
  });

  @override
  State<MerryMakinWelcomeScreen> createState() =>
      _MerryMakinWelcomeScreenState();
}

class _MerryMakinWelcomeScreenState extends State<MerryMakinWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: generalAppLevelPadding / 2,
            right: generalAppLevelPadding / 2,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                ProText(
                  "Merry",
                  textStyle: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w200,
                      color: Theme.of(context).colorScheme.primary),
                  maxLines: 1,
                  textScaler: TextScaler.noScaling,
                ),
                ProText(
                  "Makin",
                  textStyle: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w200,
                      color: Theme.of(context).colorScheme.primary),
                  maxLines: 1,
                  textScaler: TextScaler.noScaling,
                ),
                const Spacer(),
                OAuthLogin(
                  userService: AppFactory().userService,
                  sprylyService: SprylyServices.MerryMakin.name,
                )
              ]),
        ),
      ),
    );
  }
}
