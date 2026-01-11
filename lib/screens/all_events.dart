import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/service/cookie_service.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_primary_button.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
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
    'past events',
  ];

  @override
  void initState() {
    super.initState();
  }

  void sortEvents(List<Event> events, {int sortMultiplier = 1}) {
    events.sort((a, b) {

      // if an event has yet to be rsvped, show it first
      if (a.getRsvpStatusForUser(widget.cookiesService.currentUser) == RSVPStatus.UNDECIDED && !a.isHostedByMe(widget.cookiesService.currentUser)) return -1;
      if (b.getRsvpStatusForUser(widget.cookiesService.currentUser) == RSVPStatus.UNDECIDED && !b.isHostedByMe(widget.cookiesService.currentUser)) return 1;

      if (a.startDateTime != null && b.startDateTime != null) {
        int comparison = b.startDateTime!.compareTo(a.startDateTime!);
        if (comparison != 0) {
          return sortMultiplier * comparison;
        }
      }

      // If only one has startDateTime, put the non-null one first
      if (a.startDateTime == null) return -1 * sortMultiplier;
      if (b.startDateTime == null) return 1 * sortMultiplier;

      // If both are null, compare createdAt
      return sortMultiplier * a.createdAt.compareTo(b.createdAt);
    });
  }

  List<Event> getFilteredEvents() {
    final now = DateTime.now();
    List<Event> filteredEvents = [];
    int sortMultiplier = 1;

    switch (selectedFilter) {
      case 'upcoming':
        filteredEvents = widget.events
            .where((event) =>
                event.startDateTime == null ||
                event.startDateTime!.isAfter(now.subtract(Duration(hours: 6))))
            .toList();
        sortMultiplier = -1;

      case 'past events':
        filteredEvents = widget.events
            .where((event) =>
                event.startDateTime != null &&
                event.startDateTime!.isBefore(now))
            .toList();

      case 'hosting':
        String? currentUserId = widget.cookiesService.currentUser?.id;
        filteredEvents = widget.events
            .where((event) => event.hosts.any((host) =>
                host.id == currentUserId &&
                (event.startDateTime == null ||
                    event.startDateTime!.isAfter(now))))
            .toList();
        sortMultiplier = -1;

      case 'attended':
        filteredEvents = widget.events
            .where((event) =>
                event.attendees != null &&
                event.attendees!.any((attendee) =>
                    attendee.user.id ==
                    widget.cookiesService.currentUser?.id) &&
                event.startDateTime != null &&
                event.startDateTime!.isBefore(now) &&
                event.getRsvpStatusForUser(widget.cookiesService.currentUser) ==
                    RSVPStatus.GOING)
            .toList();

      default:
        filteredEvents = widget.events;
    }
    sortEvents(filteredEvents, sortMultiplier: sortMultiplier);
    return filteredEvents;
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
    } else if (selectedFilter == "past") {
      title = "No past events";
      subtitle = "Your past events, hosted or attended, show up right here!";
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
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
                  Padding(
                      padding: EdgeInsets.all(generalAppLevelPadding),
                      child: ProText("Create Event")),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // buildEventFilterSelection(constraints),
              const SizedBox(height: generalAppLevelPadding * 2),
              ProListView(
                  scrollDirection: Axis.horizontal,
                  listItems: buildEventCards(filteredEvents, constraints,
                      viewportFraction: 0.85),
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
            // Divider(),
            ProListItem(
              key: Key("Upcoming"),
              title: ProText("Upcoming"),
              leading: Icon(Icons.calendar_month),
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
              key: Key("Past Events"),
              title: ProText("Past Events"),
              leading: Icon(Icons.refresh),
              swipeForEditAndDelete: false,
              onTap: () => {
                setState(() {
                  selectedFilter = "past events";
                  context.pop();
                })
              },
            ),
            Divider(),
            ProListItem(
              key: Key("Hosting"),
              title: ProText("Hosting"),
              leading: Icon(Icons.star),
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
              leading: Icon(Icons.check),
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
          // capitalize the first letter of every word of the selected filter
          selectedFilter
              .split(' ')
              .map((word) =>
                  word.substring(0, 1).toUpperCase() + word.substring(1))
              .join(' '),
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
          title: Padding(
            padding: const EdgeInsets.all(generalAppLevelPadding / 2),
            child: buildLeadingFilterSelector(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                  right: generalAppLevelPadding / 2,
                  top: generalAppLevelPadding / 2),
              child: InkWell(
                  onTap: () {
                    AppRouter.goToProfile(context);
                  },
                  child: ProUserAvatar(
                    radius: 24,
                    user: AppFactory().cookiesService.locallyAvailableUserInfo!,
                  )),
            ),
            SizedBox(
              width: generalAppLevelPadding,
            )
          ],
        ),
        floatingActionButton: IconButton.filled(
          padding: EdgeInsets.all(0),
          icon: SizedBox(
            width: 56,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purpleAccent,
                    Colors.blueAccent,
                  ],
                ),
              ),
              child: Icon(
                Icons.add,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
          onPressed: () {
            AppRouter.goToNewEvent(context);
          },
        ),
        body: buildEvents(context));
  }
}
