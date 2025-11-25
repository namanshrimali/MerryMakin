import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/spryly_services.dart';
import 'package:merrymakin/commons/providers/user_provider.dart';
import 'package:merrymakin/commons/screen/update_user_screen.dart';
import 'package:merrymakin/commons/widgets/pro_scaffold.dart';
import 'package:merrymakin/factory/app_factory.dart';
import 'package:merrymakin/providers/events_provider.dart';
import 'package:merrymakin/screens/all_events.dart';
import 'package:merrymakin/screens/welcome.dart';
import 'package:merrymakin/service/event_service.dart';

import '../commons/models/rsvp.dart';
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
    ref.watch(eventProvider);
    ref.watch(userProvider);

    return FutureBuilder(
        future: Future.wait([
          allEvents,
          cookiesService.hasOnboarded,
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
              snapshot.data == null ? [] : (snapshot.data![0] as List<Event>)
                ..sort((a, b) {
                  // If both have startDateTime, compare them

                  // event with undecided rsvp status for the user are first in order of the sorting.

                  if (a.getRsvpStatusForUser(cookiesService.currentUser) == RSVPStatus.UNDECIDED) {
                    return 1;
                  }
                  if (b.getRsvpStatusForUser(cookiesService.currentUser) == RSVPStatus.UNDECIDED) {
                    return -1;
                  }

                  if (a.startDateTime != null && b.startDateTime != null) {
                    int comparison =  a.startDateTime!.compareTo(b.startDateTime!);
                    if (comparison == 0) {
                      return a.createdAt.compareTo(b.createdAt);
                    }
                    return comparison;
                  }

                  // If only one has startDateTime, put the non-null one first
                  if (a.startDateTime != null) return -1;
                  if (b.startDateTime != null) return 1;

                  // If both are null, compare createdAt
                  return a.createdAt.compareTo(b.createdAt);
                });

          if (cookiesService.currentUser == null) {
            return const MerryMakinWelcomeScreen();
          }
          if (cookiesService.currentUser!.givenName == null ||
              cookiesService.currentUser!.givenName == "" ||
              snapshot.data![1] == false) {
            return AddOrEditUser(
                sprylyService: SprylyServices.MerryMakin.name,
                cookiesService: cookiesService,
                userService: userService,
                imageService: AppFactory().userIconService,
                title: cookiesService.currentUser!.givenName == null || cookiesService.currentUser!.givenName == "" ? "Drop Your Name, Let’s Get This Party Lit!" : "Let's Double-Check Your Info!", showWarning: false);
          }
          return AllEventsScreen(
              events: events, cookiesService: cookiesService);
        });
  }
}
