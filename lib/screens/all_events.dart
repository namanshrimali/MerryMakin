import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/service/cookie_service.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_primary_button.dart';
import 'package:merrymakin/commons/widgets/pro_filter_chip.dart';
import 'package:merrymakin/commons/widgets/pro_image_card.dart';
import 'package:merrymakin/commons/widgets/pro_list_view.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/config/router.dart';
import 'package:merrymakin/widgets/event_card.dart';

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
          imageHeight: constraints.maxHeight * 0.65,
          imageUrl: "",
          title: title,
          subtitle: Column(
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
        height: constraints.maxHeight * 0.65,
        width: itemWidth,
      );
    }).toList();
  }

  Widget buildEventFilterSelection(constraints) {
    final eventCounts = getEventCounts();

    return Padding(
      padding: const EdgeInsets.only(
          left: generalAppLevelPadding, right: generalAppLevelPadding),
      child: SizedBox(
        height: constraints.maxHeight * 0.1,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: generalAppLevelPadding),
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = selectedFilter == filter;

            return Padding(
              padding: const EdgeInsets.only(right: generalAppLevelPadding / 2),
              child: ProFilterChip(
                label: filter,
                isSelected: isSelected,
                count: eventCounts[filter],
                onSelected: (bool selected) {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
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
              buildEventFilterSelection(constraints),
              const SizedBox(height: generalAppLevelPadding),
              SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.7,
                  child: ProListView(
                      scrollDirection: Axis.horizontal,
                      listItems: buildEventCards(filteredEvents, constraints,
                          viewportFraction: 0.85),
                      height: constraints.maxHeight * 0.7,
                      viewportFraction: 0.9)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildEvents(context);
  }
}
