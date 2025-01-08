import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/user_api.dart';
import '../service/user_service.dart';
import '../utils/constants.dart';
import 'buttons/pro_button_with_icon_and_text.dart';
import 'pro_text.dart';
import 'pro_user_card.dart';
import '../models/user.dart';

class ProUserProfile extends StatelessWidget {
  final String username;
  final User? user;
  final String? jwtToken;
  final UserService userService;
  final String sprylyService;
  const ProUserProfile({
    super.key,
    required this.username,
    required this.user,
    this.jwtToken,
    required this.userService,
    required this.sprylyService,
  });

  Widget getUserProfileContent(final User user) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(generalAppLevelPadding),
          child: Column(
            children: [
              ProUserCard(
                user: user,
                isDisplayCard: false,
                userService: userService,
                sprylyService: sprylyService,
              ),
              // joinedCard,
              SizedBox(
                height: generalAppLevelPadding,
              ),
              ProButtonWithIconAndText(
                icon: Icons.add,
                onPressed: () {},
                text: "Add friend",
                isPrimary: true,
                iconAtPrefix: true,
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || username == user!.userNameForDisplay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
    }

    return FutureBuilder(
        future: findByUsername(username, jwtToken),
        builder: (context, AsyncSnapshot<User?> userSnapshot) {
          Widget body;
          if (userSnapshot.connectionState != ConnectionState.done) {
            body = CircularProgressIndicator();
          } else {
            User? user = userSnapshot.data;
            body = user == null
                ? ProText("No user found ${username}.")
                : getUserProfileContent(user);
          }

          return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      context.go("/");
                    },
                    icon: Icon(Icons.close)),
              ),
              body: body);
        });
  }
}
