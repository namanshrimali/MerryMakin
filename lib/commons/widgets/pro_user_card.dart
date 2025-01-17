import 'package:flutter/material.dart';
import '../service/user_service.dart';
import '../widgets/oauth_login.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/constants.dart';
import '../widgets/cards/pro_card.dart';
import '../widgets/pro_text.dart';
import '../models/user.dart';

class ProUserCard extends StatefulWidget {
  final User? user;
  final bool isDisplayCard;
  final double? height;
  final UserService userService;
  final String sprylyService;
  final String userHardLinkText;
  const ProUserCard(
      {super.key,
      required this.user,
      this.isDisplayCard = true,
      this.height,
      required this.userService,
      required this.sprylyService,
      required this.userHardLinkText});

  @override
  State<ProUserCard> createState() => _ProUserCardState();
}

class _ProUserCardState extends State<ProUserCard> {
  // Widget userCard() {
  //   if (widget.user == null) {
  //     return OAuthLogin(
  //       onPressedCallback: () {
  //         setState(() {});
  //       },
  //     );
  //   }
  //   return SizedBox(
  //       height: height,
  //       child: ProUserCard(
  //         user: widget.user,
  //       ));
  // }

  Widget cardContent(User user) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Opacity(
                opacity: 0.0,
                child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.qr_code, size: 20),
                ),
              ),
              CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.account_circle,
                  size: 50,
                ),
                backgroundImage:
                    user.photoUrl == null ? null : NetworkImage(user.photoUrl!),
              ),
              Opacity(
                opacity: widget.isDisplayCard ? 1 : 0,
                child: IconButton(
                  onPressed: () {
                    Share.share(widget.userHardLinkText);
                  },
                  icon: Icon(Icons.ios_share, size: 20),
                ),
              ),
            ],
          ),
          SizedBox(
            height: generalAppLevelPadding / 2,
          ),
          ProText(
            user.getFirstAndLastName(),
            textStyle: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(
            height: generalAppLevelPadding / 4,
          ),
          ProText('@${user.userNameForDisplay}')
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final Widget cardContent = widget.user == null
        ? OAuthLogin(
            userService: widget.userService,
            sprylyService: widget.sprylyService,
            onPressedCallback: () {
              setState(() {});
            },
          )
        : this.cardContent(widget.user!);
    return SizedBox(
      height: widget.height,
      child: this.widget.isDisplayCard
          ? ProCard(
              child: cardContent,
            )
          : cardContent,
    );
  }
}
