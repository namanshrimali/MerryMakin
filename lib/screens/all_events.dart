import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/service/cookie_service.dart';
import 'package:merrymakin/commons/service/cookies_service_mobile.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/pro_filter_chip.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_greetings.dart';
import 'package:merrymakin/widgets/event_card.dart';

class AllEventsScreen extends ConsumerStatefulWidget {
  final List<Event> events;
  final CookiesService cookiesService;
  const AllEventsScreen({super.key, required this.events, required this.cookiesService});

  @override
  ConsumerState<AllEventsScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<AllEventsScreen> {
  String selectedFilter = 'upcoming';

  final List<String> filters = [
    'upcoming',
    'hosting',
    'attended',
    'past',
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

  Widget buildEvents(BuildContext context) {
    final filteredEvents = getFilteredEvents();
    final eventCounts = getEventCounts();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: constraints.maxHeight * 0.05),
              ProGreetings(
                user: widget.cookiesService.currentUser,
              
              ),
              SizedBox(
                height: constraints.maxHeight * 0.1,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(
                      right: generalAppLevelPadding),
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
              const SizedBox(height: generalAppLevelPadding),
              if (filteredEvents.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(generalAppLevelPadding),
                  child: ProText(
                    'Create your event! Start by tapping the + button at the bottom right corner',
                    textStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: constraints.maxHeight * 0.8,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    // padding: const EdgeInsets.symmetric(
                    //     horizontal: generalAppLevelPadding),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return EventCard(event: event);
                    },
                  ),
                ),
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
