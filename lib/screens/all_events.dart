import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/service/cookie_service.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_primary_button.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:merrymakin/commons/widgets/pro_filter_chip.dart';
import 'package:merrymakin/commons/widgets/pro_image_card.dart';
import 'package:merrymakin/commons/widgets/pro_list_view.dart';
import 'package:merrymakin/commons/widgets/pro_scaffold.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/config/router.dart';
import 'package:merrymakin/widgets/event_card.dart';

import '../commons/widgets/pro_list_item.dart';
import '../commons/widgets/pro_user_avatar.dart';
import '../factory/app_factory.dart';

class AllEventsScreen extends ConsumerStatefulWidget {
  final List<Event> events;
  final CookiesService cookiesService;
  const AllEventsScreen(
      {super.key, required this.events, required this.cookiesService});

  @override
  ConsumerState<AllEventsScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<AllEventsScreen> {
  String selectedFilter = 'upcoming';

  final List<String> filters = [
    'upcoming',
    'hosting',
    'attended',
    // 'past',
  ];

  @override
  void initState() {
    super.initState();
  }

  List<Event> getFilteredEvents() {
    final now = DateTime.now();

    switch (selectedFilter) {
      case 'upcoming':
        return widget.events
            .where((event) =>
                event.startDateTime == null ||
                event.startDateTime!.isAfter(now))
            .toList();

      case 'past':
        return widget.events
            .where((event) =>
                event.startDateTime != null &&
                event.startDateTime!.isBefore(now))
            .toList();

      case 'hosting':
        String? currentUserId = widget.cookiesService.currentUser?.id;
        return widget.events
            .where((event) => event.hosts.any((host) =>
                host.id == currentUserId &&
                (event.startDateTime == null ||
                    event.startDateTime!.isAfter(now))))
            .toList();

      case 'attended':
        return widget.events
            .where((event) =>
                event.attendees != null &&
                event.attendees!.any((attendee) =>
                    attendee.user.id ==
                    widget.cookiesService.currentUser?.id) &&
                event.startDateTime != null &&
                event.startDateTime!.isBefore(now))
            .toList();

      default:
        return widget.events;
    }
  }

  Map<String, int> getEventCounts() {
    final now = DateTime.now();
    String? currentUserId = widget.cookiesService.currentUser?.id;

    return {
      'upcoming': widget.events
          .where((event) =>
              event.startDateTime == null || event.startDateTime!.isAfter(now))
          .length,
      'past': widget.events
          .where((event) =>
              event.startDateTime != null && event.startDateTime!.isBefore(now))
          .length,
      'hosting': widget.events
          .where((event) => event.hosts.any((host) =>
              host.id == currentUserId &&
              (event.startDateTime == null ||
                  event.startDateTime!.isAfter(now))))
          .length,
      'attended': widget.events
          .where((event) =>
              event.attendees != null &&
              event.attendees!
                  .any((attendee) => attendee.user.id == currentUserId) &&
              event.startDateTime != null &&
              event.startDateTime!.isBefore(now))
          .length,
    };
  }

  Widget buildCreateEventCard(constraints, {double? width}) {
    String title = "";
    String subtitle = "";
    if (selectedFilter == "upcoming") {
      title = "No upcoming events";
      subtitle = "Your next event, hosted or attended, show up right here! 🎉";
    } else if (selectedFilter == "hosting") {
      title = "No hosted events";
      subtitle = "Your next hosted event show up right here!";
    } else if (selectedFilter == "attended") {
      title = "No attended events";
      subtitle = "Your past events, hosted or attended, show up right here! 🎉";
    }
    return Column(
      children: [
        ProImageCard(
          textPosition: TextPosition.center,
          radius: generalAppLevelPadding * 2,
          width: width ?? constraints.maxWidth,
          imageHeight: constraints.maxHeight * 0.75,
          imageUrl: "",
          title: title,
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: generalAppLevelPadding,
              ),
              ProText(
                subtitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: generalAppLevelPadding,
              ),
            ],
          ),
          thirdRow: selectedFilter == "attended"
              ? null
              : ProPrimaryButton(
                  ProText("Create Event"),
                  onPressed: () {
                    AppRouter.goToNewEvent(context);
                  },
                ),
        ),
        Spacer(),
      ],
    );
  }

  List<dynamic> buildEventCards(filteredEvents, constraints,
      {double? viewportFraction}) {
    final itemWidth = viewportFraction != null
        ? constraints.maxWidth * viewportFraction
        : constraints.maxWidth;

    if (filteredEvents.length == 0) {
      return [buildCreateEventCard(constraints, width: itemWidth)];
    }
    return filteredEvents.map((event) {
      return EventCard(
        event: event,
        height: constraints.maxHeight * 0.75,
        width: itemWidth,
      );
    }).toList();
  }

  Widget buildEvents(BuildContext context) {
    final filteredEvents = getFilteredEvents();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // buildEventFilterSelection(constraints),
              const SizedBox(height: generalAppLevelPadding * 2),

              ProListView(
                  scrollDirection: Axis.horizontal,
                  listItems: buildEventCards(filteredEvents, constraints,
                      viewportFraction: filteredEvents.length == 0 ? 1 : 0.85),
                  height: constraints.maxHeight * 0.8,
                  viewportFraction: 0.9),
            ],
          ),
        );
      },
    );
  }

  buildFilterSelectionBottomModal() {
    return openProBottomModalSheet(
        context,
        Column(
          children: [
            SizedBox(
              height: generalAppLevelPadding,
            ),
            // Divider(),
            ProListItem(
              key: Key("Upcoming"),
              title: ProText("Upcoming"),
              swipeForEditAndDelete: false,
              onTap: () => {
                setState(() {
                  selectedFilter = "upcoming";
                  context.pop();
                })
              },
            ),
            Divider(),
            ProListItem(
              key: Key("Hosting"),
              title: ProText("Hosting"),
              swipeForEditAndDelete: false,
              onTap: () => {
                setState(() {
                  selectedFilter = "hosting";
                  context.pop();
                })
              },
            ),
            Divider(),
            ProListItem(
              key: Key("Attended"),
              title: ProText("Attended"),
              swipeForEditAndDelete: false,
              onTap: () => {
                setState(() {
                  selectedFilter = "attended";
                  context.pop();
                })
              },
            ),
          ],
        ));
  }

  Widget buildLeadingFilterSelector() {
    return InkWell(
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      onTap: () {
        buildFilterSelectionBottomModal();
      },
      child: Row(children: [
        ProText(
          toBeginningOfSentenceCase(selectedFilter),
          textStyle: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
        ),
        SizedBox(width: generalAppLevelPadding / 4),
        Icon(Icons.arrow_drop_down)
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProScaffold(
        appBar: AppBar(
          title: buildLeadingFilterSelector(),
          actions: [
            InkWell(
                onTap: () {
                  AppRouter.goToProfile(context);
                },
                child: ProUserAvatar(
                  radius: 24,
                  user: AppFactory().cookiesService.locallyAvailableUserInfo!,
                )),
            SizedBox(
              width: generalAppLevelPadding,
            )
          ],
        ),
        floatingActionButton: IconButton.filled(
          icon: Icon(
            Icons.add,
            size: 42,
          ),
          onPressed: () {
            AppRouter.goToNewEvent(context);
          },
        ),
        body: buildEvents(context));
  }
}
