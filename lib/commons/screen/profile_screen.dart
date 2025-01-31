import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/cookie_service.dart';
import '../utils/constants.dart';
import '../widgets/pro_list_item.dart';
import '../widgets/pro_list_view.dart';
import '../widgets/pro_madeby_sprylylabs.dart';
import '../widgets/pro_text.dart';
import '../widgets/pro_user_card.dart';
import '../service/cookies_service_mobile.dart';
import '../service/user_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final UserService userService;
  final CookiesService cookiesService;
  final String sprylyService;
  final Function? onLogout;
  final String deepLinkText;
  const ProfileScreen(
      {super.key,
      required this.userService,
      required this.cookiesService,
      required this.sprylyService,
      this.onLogout,
      required this.deepLinkText});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  List<Widget> get accountSettings {
    return [
      const ProText("Account Settings"),
      ProListItem(
        key: const Key("delete-account"),
        title: const ProText('Delete Account'),
        onTap: () {},
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        final double height = constraints.maxHeight;
        return ProListView(listItems: [
          ProUserCard(
              height: height * 0.4,
              user: widget.cookiesService.currentUser,
              userService: widget.userService,
              sprylyService: widget.sprylyService,
              userHardLinkText: widget.deepLinkText), // userCard is not ready
          const SizedBox(
            height: generalAppLevelPadding * 2,
          ),
          const ProMadeBySprylyLabs()
        ], height: height);
      }),
    );
  }
}
