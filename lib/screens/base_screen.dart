import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/spryly_services.dart';
import 'package:merrymakin/commons/providers/user_provider.dart';
import 'package:merrymakin/commons/screen/profile_screen.dart';
import 'package:merrymakin/commons/screen/update_user_screen.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_primary_button.dart';
import 'package:merrymakin/commons/widgets/pro_base_screen.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_stacked_fab.dart';
import 'package:merrymakin/commons/widgets/pro_scaffold.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/config/router.dart';
import 'package:merrymakin/factory/app_factory.dart';
import 'package:merrymakin/providers/events_provider.dart';
import 'package:merrymakin/screens/all_events.dart';
import 'package:merrymakin/screens/welcome.dart';
import 'package:merrymakin/service/event_service.dart';

import '../commons/service/cookie_service.dart';

class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({super.key});

  @override
  ConsumerState<BaseScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<BaseScreen> {
  final CookiesService cookiesService = AppFactory().cookiesService;
  @override
  Widget build(BuildContext context) {
    ProStackedFabObject addEvent = ProStackedFabObject(
        icon: Icons.add,
        title: "New Event",
        actionButtonText:
            "New Party\nOne epic event of fun, music, and good vibes all in one go.",
        onTap: () {
          AppRouter.goToNewEvent(context);
        });
    // ProStackedFabObject addCelebration = ProStackedFabObject(
    //     icon: Icons.celebration,
    //     title: "New Celebration",
    //     actionButtonText:
    //     "New Celebration\nMultiple events, packed with parties, rituals, and gatherings—all for one big reason to celebrate 🥳",
    //         // "New Celebration\nSeries of events and moments spread out to keep the fun going! 🎉✨",
    //     onTap: () {
    //       context.push('/events/celebration/new');
    //     });
    ref.watch(eventProvider);
    ref.watch(userProvider);

    return FutureBuilder(
        future: Future.wait([
          allEvents,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ProScaffold(
              appBar: AppBar(),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return const MerryMakinWelcomeScreen();
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

          if (cookiesService.currentUser == null) {
            AppRouter.goToLogin(context);
          }
          if (cookiesService.currentUser!.givenName == null ||
              cookiesService.currentUser!.givenName == "") {
            return AddOrEditUser(
                sprylyService: SprylyServices.MerryMakin.name,
                cookiesService: cookiesService,
                userService: userService,
                imageService: AppFactory().userIconService,
                title: "Drop Your Name, Let’s Get This Party Lit!");
          }
          return AllEventsScreen(
              events: events, cookiesService: cookiesService);
        });
  }
}
