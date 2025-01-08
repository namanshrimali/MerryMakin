import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../widgets/pro_bottom_modal_sheet.dart';
import '../widgets/pro_contact_us.dart';
import '../widgets/pro_list_item.dart';
import '../widgets/pro_list_view.dart';
import '../widgets/pro_madeby_sprylylabs.dart';
import '../widgets/pro_text.dart';
import '../widgets/pro_user_card.dart';
import '../models/country_currency.dart';
import './update_currency.dart';
import '../service/cookies_service.dart';
import '../service/user_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final UserService userService;
  final CookiesService cookiesService;
  final String sprylyService;
  final Function? onLogout;
  const ProfileScreen(
      {super.key,
      required this.userService,
      required this.cookiesService,
      required this.sprylyService,
      this.onLogout});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProListItem get currencyUpdateListItem {
    return ProListItem(
      key: const Key("0"),
      title: const ProText("Transactions Currency"),
      trailing: ProText(
          CookiesService.locallyStoredCountryCurrency.getCurrencySymbol()),
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
      const ProText("Preferences and Feedback"),
      currencyUpdateListItem,
      ProContactUs(),
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
              user: CookiesService.locallyAvailableUserInfo,
              userService: widget.userService,
              sprylyService: widget.sprylyService), // userCard is not ready
          const SizedBox(
            height: generalAppLevelPadding,
          ),
          ...preferences,
          if (CookiesService.locallyAvailableUserInfo != null)
            TextButton(
                onPressed: () {
                  widget.onLogout?.call();
                },
                child: const ProText('Log Out')),
          const SizedBox(
            height: generalAppLevelPadding * 2,
          ),
          const ProMadeBySprylyLabs()
        ], height: height);
      }),
    );
  }
}
