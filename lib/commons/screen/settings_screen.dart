import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/api/google_sign_in_web.dart';
import 'package:merrymakin/commons/widgets/pro_scaffold.dart';
import 'package:merrymakin/config/router.dart';
import '../providers/navigation_provider.dart';
import '../models/country_currency.dart';
import '../providers/user_provider.dart';
import '../service/user_service.dart';
import '../widgets/buttons/pro_outlined_button.dart';
import '../api/google_sign_in.dart';
import '../screen/update_currency.dart';
import '../widgets/pro_bottom_modal_sheet.dart';
import '../widgets/pro_list_view.dart';
import '../widgets/pro_list_item.dart';
import '../widgets/pro_text.dart';
import '../widgets/pro_contact_us.dart';
import '../utils/constants.dart';
import '../service/cookie_service.dart';
class SettingsScreen extends ConsumerStatefulWidget {
  final CookiesService cookiesService;
  final UserService userService;
  final Function? onLogout;

  const SettingsScreen({
    super.key,
    required this.cookiesService,
    required this.userService,
    this.onLogout,
  });

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  ProListItem get currencyUpdateListItem {
    return ProListItem(
      key: const Key("0"),
      title: const ProText("Transactions Currency"),
      trailing: ProText(
          widget.cookiesService.locallyStoredCountryCurrency.getCurrencySymbol()),
      swipeForEditAndDelete: false,
      onTap: () {
        openProBottomModalSheet(
            context,
            titleText: "Update currency for all transactions",
            UpdateCurrency(
              cookiesService: widget.cookiesService,
              onUpdate: (CountryCurrency countryCurrency) {},
            )).then((updatedCountryCurrency) {
          if (updatedCountryCurrency != null) {
            setState(() {});
          }
        });
      },
    );
  }

  List<Widget> get preferences {
    return [
      const ProText("Preferences"),
      currencyUpdateListItem,
    ];
  }

  List<Widget> get feedback {
    return [
      const ProText("Feedback"),
      ProContactUs(appName: "MerryMakin"),
    ];
  }

  List<Widget> get accountSettings {
    return [
      const ProText("Account Settings"),
      ProListItem(
        swipeForEditAndDelete: false,
        key: const Key("delete-account"),
        title: const ProText('Delete Account',
            textStyle: TextStyle(color: Colors.red)),
        leading: const Icon(Icons.delete, color: Colors.red),
        onTap: () async {
          // show confirmation dialog
          final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const ProText('Delete Account'),
                content: const ProText(
                    maxLines: 3,
                    'Are you sure you want to delete your account? It will delete all your data and you will not be able to recover it.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const ProText('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const ProText('Delete')),
                ],
              );
            },
          );
          if (confirm == true) {
            widget.userService.deleteUser().whenComplete(() {
              onLogout(context).call();
            });
          }
        },
      ),
    ];
  }

  Function onLogout(BuildContext context) {
    return () {
      widget.onLogout?.call();
      if (kIsWeb) {
        // TODO: sign out from web
        GoogleSignInWeb.signOut();
      } else {
        Platform.isAndroid ? GoogleSignInApi.signOut() : () {};
      }
      ref.read(userProvider.notifier).logout();
      ref.read(pageIndexProvider.notifier).gotoNewPage(0);
      widget.onLogout?.call();
      AppRouter.goHome(context);
    };
  }

  @override
  Widget build(BuildContext context) {
    return ProScaffold(
      appBar: AppBar(
        title: const ProText('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AppRouter.goHome(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: const EdgeInsets.all(generalAppLevelPadding),
            child: ProListView(
              height: constraints.maxHeight,
              listItems: [
                ...preferences,
                const SizedBox(height: generalAppLevelPadding),
                ...feedback,
                const SizedBox(height: generalAppLevelPadding),
                if (widget.cookiesService.locallyAvailableUserInfo != null)
                  ...accountSettings,
                if (widget.cookiesService.locallyAvailableUserInfo != null) ...[
                  const SizedBox(height: generalAppLevelPadding),
                  ProOutlinedButton(
                      onPressed: () {
                        onLogout(context).call();
                      },
                      child: ProText('Log Out')),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
