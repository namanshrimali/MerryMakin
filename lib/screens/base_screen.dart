import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/spryly_services.dart';
import 'package:merrymakin/commons/providers/user_provider.dart';
import 'package:merrymakin/commons/screen/profile_screen.dart';
import 'package:merrymakin/commons/service/cookies_service.dart';
import 'package:merrymakin/commons/widgets/pro_base_screen.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_stacked_fab.dart';
import 'package:merrymakin/factory/app_factory.dart';
import 'package:merrymakin/providers/events_provider.dart';
import 'package:merrymakin/screens/all_events.dart';
import 'package:merrymakin/screens/welcome.dart';
import 'package:merrymakin/service/event_service.dart';

import '../commons/resources.dart';

class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({super.key});

  @override
  ConsumerState<BaseScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<BaseScreen> {
  @override
  Widget build(BuildContext context) {
    ProStackedFabObject addEvent = ProStackedFabObject(
        icon: Icons.add,
        title: "New Event",
        onTap: () {
          context.push('/events/new');
        });
    ref.watch(eventProvider);
    ref.watch(userProvider);

    return FutureBuilder(
        future: Future.wait([
          allEvents,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold();
          }
          final List<Event> events =
              snapshot.data == null ? [] : snapshot.data![0]
                ..sort((a, b) {
                  // If both have startDateTime, compare them
                  if (a.startDateTime != null && b.startDateTime != null) {
                    return a.startDateTime!.compareTo(b.startDateTime!);
                  }

                  // If only one has startDateTime, put the non-null one first
                  if (a.startDateTime != null) return -1;
                  if (b.startDateTime != null) return 1;

                  // If both are null, compare createdAt
                  return a.createdAt.compareTo(b.createdAt);
                });

          List<ProBaseScreenObject> baseScreenObjectList = [
            ProBaseScreenObject(
                widget: AllEventsScreen(events: events),
                // widget: AddOrEditAccount(routeArgs: null,),
                icon: Icons.home,
                title: "Home",
                [addEvent]),
            ProBaseScreenObject(
                appBarActions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      context.push('/settings');
                    },
                  ),
                ],
                widget: ProfileScreen(
                  userService: AppFactory().userService,
                  cookiesService: AppFactory().cookiesService,
                  sprylyService: SprylyServices.MerryMakin.name,
                  deepLinkText: DEEP_LINK_BEFRIEND_USER_TEXT,
                ),
                icon: Icons.account_circle,
                title: "Profile",
                []),
          ];
          if (CookiesService.locallyAvailableUserInfo == null) {
            return const MerryMakinWelcomeScreen();
          }
          return ProBaseScreen(
            baseScreenObjectList: baseScreenObjectList,
            withBottonNavigationBar: true,
            withFloatingActionButton: true,
          );
        });
  }
}
