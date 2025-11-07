import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merrymakin/commons/widgets/pro_scaffold.dart';
import '../../config/router.dart';
import '../service/cookie_service.dart';
import '../utils/constants.dart';
import '../widgets/pro_list_item.dart';
import '../widgets/pro_list_view.dart';
import '../widgets/pro_madeby_sprylylabs.dart';
import '../widgets/pro_text.dart';
import '../widgets/pro_user_card.dart';
import '../service/user_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final UserService userService;
  final CookiesService cookiesService;
  final String sprylyService;
  final Function? onLogout;
  final String? deepLinkText;
  const ProfileScreen(
      {super.key,
      required this.userService,
      required this.cookiesService,
      required this.sprylyService,
      this.onLogout,
      this.deepLinkText});

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
    return ProScaffold(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
        ),
        onPressed: () => AppRouter.goHome(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            AppRouter.goToSettings(context);
          },
        ),
      ],
      body: SafeArea(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          final double height = constraints.maxHeight;
          return Padding(
            padding: const EdgeInsets.all(generalAppLevelPadding),
            child: ProListView(listItems: [
              ProUserCard(
                  height: height * 0.4,
                  user: widget.cookiesService.currentUser,
                  userService: widget.userService,
                  sprylyService: widget.sprylyService,
                  userHardLinkText: widget.deepLinkText ??
                      '${widget.sprylyService}'), // userCard is not ready
              const SizedBox(
                height: generalAppLevelPadding * 2,
              ),
              const ProMadeBySprylyLabs()
            ], height: height),
          );
        }),
      ),
    );
  }
}
