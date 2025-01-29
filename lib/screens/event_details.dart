import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/country_currency.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/event_attendee.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/service/cookies_service.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_outlined_button.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_stacked_fab.dart';
import 'package:merrymakin/commons/widgets/cards/pro_card.dart';
import 'package:merrymakin/commons/widgets/pro_add_comment.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:merrymakin/commons/widgets/pro_carousel.dart';
import 'package:merrymakin/commons/widgets/pro_font_selector.dart';
import 'package:merrymakin/commons/widgets/pro_list_view.dart';
import 'package:merrymakin/commons/widgets/pro_snackbar.dart';
import 'package:merrymakin/commons/widgets/pro_tab_view.dart';
import 'package:merrymakin/commons/widgets/pro_theme_effects.dart';
import 'package:merrymakin/commons/widgets/pro_user_avatar.dart';
import 'package:merrymakin/providers/events_provider.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/service/event_service.dart';
import 'package:share_plus/share_plus.dart';
import '../commons/widgets/pro_user_comment.dart';
import '../commons/themes/pro_themes.dart';
import '../commons/widgets/pro_share_sheet.dart';
class EventDetailsScreen extends ConsumerStatefulWidget {
  final String? eventId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  Event? event;
    ThemeData? eventTheme;
    ProThemeType themeType = ProThemeType.classic;
    ProEffectType effectType = ProEffectType.none;
  List<Widget> _buildInfoRow(IconData? icon, Widget content) {
    return [
      const SizedBox(height: generalAppLevelPadding),
      Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8)],
          content,
        ],
      )
    ];
  }

  void _showOptionsModal(BuildContext context, Event event) {
    final String eventType = event.subEvents != null && event.subEvents!.isNotEmpty ? "Celebration" : "Event";
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: ProText('Edit ${eventType}'),
                onTap: () {
                  if (!event
                      .isHostedByMe(CookiesService.locallyAvailableUserInfo)) {
                    return;
                  }
                  Navigator.pop(context); // Close the bottom sheet
                  if (event.subEvents != null && event.subEvents!.isNotEmpty) {
                    context.push('/events/${event.id}/celebration/edit');
                  } else {
                    context.push('/events/${event.id}/edit');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: ProText(
                  'Delete ${eventType}',
                  textStyle: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  // Close the bottom sheet
                  Navigator.pop(context);

                  // Show confirmation dialog
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: ProText('Delete ${eventType}'),
                        content: const ProText(
                          'Are you sure you want to delete this event?',
                          maxLines: 2,
                        ),
                        actions: [
                          TextButton(
                            child: const ProText('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: const ProText(
                              'Delete',
                              textStyle: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              deleteEvent(event.id!).then((value) {
                                ref
                                    .read(eventProvider.notifier)
                                    .updateEvent(event);
                                context.go("/");
                              });
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    await deleteEvent(event.id!);
                    if (context.mounted) {
                      Navigator.pop(context); // Return to previous screen
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildEventTime(Event receivedEvent) {
    if (receivedEvent.subEvents == null || receivedEvent.subEvents!.isEmpty)
      return _buildInfoRow(
        Icons.access_time,
        Row(
        children: [
          ProText(
              receivedEvent.formattedStartDateTime,
            ),
          ],
        ),
      );
    return [];
  }

  List<Widget> _buildEventLocation(Event receivedEvent, double width) {
    if (receivedEvent.location != null && receivedEvent.location!.isNotEmpty)
      return _buildInfoRow(
        Icons.location_on,
        Row(
          children: [
            SizedBox(
              width: width,
              child: ProText(
                receivedEvent.location!,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
      );
    return [];
  }

  List<Widget> _buildEventSpots(Event receivedEvent) {
    if (receivedEvent.spots != null && receivedEvent.spots! > 0)
      return _buildInfoRow(
        Icons.person,
        ProText(
          '${receivedEvent.spots} spots',
          textStyle: const TextStyle(),
        ),
      );
    return [];
  }

  List<Widget> _buildEventCostPerSpot(Event receivedEvent) {
    if (receivedEvent.costPerSpot != null && receivedEvent.costPerSpot! > 0)
      return _buildInfoRow(
        Icons.loyalty,
        ProText(
          '${receivedEvent.countryCurrency!.getCurrencySymbol()}${receivedEvent.costPerSpot} per person',
          textStyle: const TextStyle(),
        ),
      );

    return [];
  }

  List<Widget> _buildEventDressCode(Event receivedEvent) {
    if (receivedEvent.dressCode != null && receivedEvent.dressCode!.isNotEmpty)
      return _buildInfoRow(
        Icons.style,
        Row(
          children: [
            ProText('Attire: '),
            ProText(receivedEvent.dressCode!, textStyle: const TextStyle()),
          ],
        ),
      );
    return [];
  }

  List<Widget> _buildEventFoodSituation(Event receivedEvent) {
    if (receivedEvent.foodSituation != null &&
        receivedEvent.foodSituation!.isNotEmpty)
      return _buildInfoRow(
        Icons.dining,
        ProText(receivedEvent.foodSituation!, textStyle: const TextStyle()),
      );
    return [];
  }

  Widget _buildEventInformation(Event receivedEvent, double width) {
    return Column(
      children: [
        ..._buildEventTime(receivedEvent),
        ..._buildEventLocation(receivedEvent, width * 0.7),
        ..._buildEventSpots(receivedEvent),
        ..._buildEventCostPerSpot(receivedEvent),
        ..._buildEventDressCode(receivedEvent),
        ..._buildEventFoodSituation(receivedEvent),
      ],
    );
  }

    Widget _buildSubEventInformation(Event receivedEvent, double width) {
    return Container(
      margin: const EdgeInsets.only(right: generalAppLevelPadding),
      child: ProCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProText(receivedEvent.name, textScaler: TextScaler.noScaling, textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500,)),
            // ProText(receivedEvent.name, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ..._buildEventTime(receivedEvent),
            ..._buildEventLocation(receivedEvent, width * 0.7),
            ..._buildEventSpots(receivedEvent),
            ..._buildEventCostPerSpot(receivedEvent),
            ..._buildEventDressCode(receivedEvent),
            ..._buildEventFoodSituation(receivedEvent),
          ],
        ),
      ),
    );
  }

  Widget _buildEventWithSubEventsInformation(Event receivedEvent, final double height, final double width) {
    return ProCarousel(
      height: height,
      viewportFraction: 1,
      showIndicators: true, 
      padEnds: false, 
      items: receivedEvent.subEvents!.map((subEvent) => _buildSubEventInformation(subEvent, width)).map((event) {
        return event;
      }).toList(),);
  }

  Widget _buildEvent(
      BuildContext context, final Event? receivedEvent, WidgetRef ref) {
    if (receivedEvent == null) {
      showSnackBar(context, 'Event not found');
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: ProText('Event not found'),
        ),
      );
    }

    // Get theme from event if it exists
    if (receivedEvent.theme != null) {
      try {
          // Get effect type from event
        effectType = receivedEvent.effect != null 
      ? ProEffectType.values.firstWhere(
          (type) => type.toString() == receivedEvent.effect,
          orElse: () => ProEffectType.none,
        )
      : ProEffectType.none;
        themeType = ProThemeType.values.firstWhere(
          (type) => type.toString() == receivedEvent.theme,
          orElse: () => ProThemeType.classic,
        );
        
        eventTheme = ProThemes.themes[themeType]?.theme;
      } catch (e) {
        // If there's any error in theme parsing, we'll use default theme
        print('Error loading theme: $e');
      }
    }

    // Use event theme or create a theme with default primary/secondary colors
    final currentTheme = eventTheme ?? Theme.of(context);

    return Theme(
      data: currentTheme,
      child: ProThemeEffects(
        themeType: themeType,
        effectType: effectType,
        child: Builder(
          builder: (context) => Scaffold(
            body: LayoutBuilder(builder: (context, constraints) {
              final double height = constraints.maxHeight;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: height * 0.6,
                    pinned: true,
                    backgroundColor: currentTheme.primaryColor,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(generalAppLevelPadding * 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () =>
                            context.canPop() ? context.pop() : context.go('/'),
                      ),
                    ),
                    actions: [
                      if (receivedEvent.isHostedByMe(CookiesService.locallyAvailableUserInfo))
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(generalAppLevelPadding * 2),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.more_horiz, color: Colors.white),
                            onPressed: () => _showOptionsModal(context, receivedEvent),
                          ),
                        ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.network(
                        receivedEvent.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(generalAppLevelPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ProText(
                              receivedEvent.name,
                              textStyle: TextStyle(
                                fontFamily: receivedEvent.font != null 
                                    ? ProFontType.values.firstWhere(
                                        (type) => type.toString() == receivedEvent.font,
                                        orElse: () => ProFontType.system,
                                      ).fontFamily
                                    : null,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: currentTheme.colorScheme.primary,
                              ),
                              maxLines: 3,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          _buildEventInformation(receivedEvent, constraints.maxWidth),
                          ..._buildInfoRow(
                            Icons.star,
                            Row(
                              children: [
                                const ProText('Hosted by '),
                                Row(
                                  children: receivedEvent.hosts.map((host) => ProUserAvatar(user: host)).toList(),
                                ),
                              ],
                            ),
                          ),
                          if (receivedEvent.description != null) ...[
                            const SizedBox(height: generalAppLevelPadding),
                            ProText(
                              receivedEvent.description!,
                              textStyle: const TextStyle(
                                height: 1.5,
                              ),
                              maxLines: 5,
                            ),
                          ],
                          if (receivedEvent.subEvents != null && receivedEvent.subEvents!.isNotEmpty) ...[
                            ...[
                              const SizedBox(height: generalAppLevelPadding),
                              _buildEventWithSubEventsInformation(receivedEvent, height * 0.3, constraints.maxWidth),
                            ]
                          ],
                          if (receivedEvent.attendees != null &&
                              !receivedEvent.isGuestListHidden &&
                              (receivedEvent
                                      .getAttendeesByRsvpStatus(RSVPStatus.GOING)
                                      .isNotEmpty ||
                                  receivedEvent
                                      .getAttendeesByRsvpStatus(RSVPStatus.MAYBE)
                                      .isNotEmpty)) ...[
                            const SizedBox(height: generalAppLevelPadding / 2),
                            _buildGuestList(receivedEvent),
                          ],
                          ...[
                            const SizedBox(height: generalAppLevelPadding / 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ProText(
                                  'Comments',
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ProOutlinedButton(
                                  onPressed: () {
                                    openProBottomModalSheet(
                                        context,
                                        ProAddComment(
                                            onUpdate: (final Comment comment) {
                                              if (receivedEvent.comments == null) {
                                                receivedEvent.comments = [];
                                              }
                                              // add comment to top of event.comments
                                              receivedEvent.comments!.add(comment);
                                              addCommentToEvent(receivedEvent,
                                                      comment, context)
                                                  .whenComplete(() {
                                                ref
                                                    .read(eventProvider.notifier)
                                                    .updateEvent(receivedEvent);
                                              });
                                            },
                                            user: CookiesService
                                                .locallyAvailableUserInfo));
                                  },
                                  child: ProText('Comment'),
                                ),
                              ],
                            ),
                            ..._buildComments(receivedEvent),
                            const SizedBox(height: 200),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
            floatingActionButton: receivedEvent.isHostedByMe(CookiesService.locallyAvailableUserInfo)
                ? buildActionButtonForHosts(context, receivedEvent)
                : buildActionButtonForGuests(context, receivedEvent, ref),
          ),
        ),
      ),
    );
  }

  Widget buildActionButtonForGuests(
      final BuildContext buildContext, final Event event, WidgetRef ref) {
    final RSVPStatus rsvpStatus =
        event.getRsvpStatusForUser(CookiesService.locallyAvailableUserInfo);
    final List<ProStackedFabObject> stackedFabs = [
      if (rsvpStatus != RSVPStatus.GOING)
        ProStackedFabObject(
            icon: RSVPStatus.GOING.getDisplayInfo().$1,
            title: RSVPStatus.GOING.getDisplayInfo().$2,
            onTap: () {
              rsvpForEvent(event, RSVPStatus.GOING,
                      CookiesService.locallyAvailableUserInfo)
                  .then((value) {
                ref.read(eventProvider.notifier).updateEvent(event);
              }).onError((error, stackTrace) =>
                      showSnackBar(context, error.toString()));
            }),
      if (rsvpStatus != RSVPStatus.MAYBE)
        ProStackedFabObject(
            icon: RSVPStatus.MAYBE.getDisplayInfo().$1,
            title: RSVPStatus.MAYBE.getDisplayInfo().$2,
            onTap: () {
              rsvpForEvent(event, RSVPStatus.MAYBE,
                  CookiesService.locallyAvailableUserInfo);
              ref.read(eventProvider.notifier).updateEvent(event);
            }),
      if (rsvpStatus != RSVPStatus.NOT_GOING)
        ProStackedFabObject(
            icon: RSVPStatus.NOT_GOING.getDisplayInfo().$1,
            title: RSVPStatus.NOT_GOING.getDisplayInfo().$2,
            onTap: () {
              rsvpForEvent(event, RSVPStatus.NOT_GOING,
                  CookiesService.locallyAvailableUserInfo);
              ref.read(eventProvider.notifier).updateEvent(event);
            })
    ];
    // Check if user has rsvp status
    if (rsvpStatus != RSVPStatus.UNDECIDED) {
      // Show RSVP status button
      return ProStackedFab(
        fabObjects: stackedFabs,
        staticButtonIcon: rsvpStatus.getDisplayInfo().$1,
        buttonText: ProText(rsvpStatus.getDisplayInfo().$2),
        buttonForegroundColor: Theme.of(buildContext).colorScheme.surface,
        buttonBackgroundColor: Theme.of(buildContext).primaryColor,
      );
    }

    // Show RSVP stacked fab for non-attendees

    return ProStackedFab(
      fabObjects: stackedFabs,
      buttonText: const ProText('RSVP'),
      buttonBackgroundColor: Theme.of(buildContext).primaryColor,
      buttonForegroundColor: Theme.of(buildContext).colorScheme.surface,
    );
  }

  Widget buildActionButtonForHosts(BuildContext context, Event event) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'attendees',
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.colorScheme.surface,
            onPressed: () {
              openProBottomModalSheet(
                  context, _buildAllAttendeesWithStatus(event));
            },
            label: Row(
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 8),
                ProText(
                  '${event.getAttendeesByRsvpStatus(RSVPStatus.GOING).length} Going',
                  textStyle: TextStyle(color: theme.colorScheme.surface),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'share',
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.colorScheme.surface,
            onPressed: () {
              openProBottomModalSheet(context, ProShareSheet(
                message: 'RSVP to ${event.name}!',
                link: 'http://merrymakin.com/${event.id}',
                userService: userService,
                onShare: () {
                  context.pop();
                }, event: event,
                themeType: themeType,
                effectType: effectType,
              ));
            },
            child: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestList(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ProText(
                    'Guest List',
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ProOutlinedButton(
                      onPressed: () {
                        openProBottomModalSheet(
                            context, _buildAllAttendeesWithStatus(event));
                      },
                      child: ProText('View All')),
                ],
              ),
              if (!event.isGuestCountHidden)
                Row(
                  children: [
                    if (event
                        .getAttendeesByRsvpStatus(RSVPStatus.GOING)
                        .isNotEmpty)
                      ProText(
                          'Going ${event.getAttendeesByRsvpStatus(RSVPStatus.GOING).length}'),
                    if (event
                            .getAttendeesByRsvpStatus(RSVPStatus.GOING)
                            .isNotEmpty &&
                        event
                            .getAttendeesByRsvpStatus(RSVPStatus.MAYBE)
                            .isNotEmpty)
                      ProText('·'),
                    if (event
                        .getAttendeesByRsvpStatus(RSVPStatus.MAYBE)
                        .isNotEmpty)
                      ProText(
                          'Maybe ${event.getAttendeesByRsvpStatus(RSVPStatus.MAYBE).length}'),
                  ],
                )
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              ...event
                  .getAttendeesByRsvpStatus(RSVPStatus.GOING)
                  .map((attendee) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ProUserAvatar(user: attendee.user),
                      ))
                  .toList(),
              ...event
                  .getAttendeesByRsvpStatus(RSVPStatus.MAYBE)
                  .map((attendee) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ProUserAvatar(user: attendee.user),
                      ))
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllAttendeesWithStatus(Event event) {
    return ProTabView(
      childrenTabTitle: [
        'Going (${event.getAttendeesByRsvpStatus(RSVPStatus.GOING).length})',
        'Maybe (${event.getAttendeesByRsvpStatus(RSVPStatus.MAYBE).length})',
        'Not Going (${event.getAttendeesByRsvpStatus(RSVPStatus.NOT_GOING).length})',
        'All (${event.attendees!.length})',
      ],
      children: [
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.GOING)),
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.MAYBE)),
        _buildAttendeeList(
            event.getAttendeesByRsvpStatus(RSVPStatus.NOT_GOING)),
        _buildAttendeeList(event.attendees!),
      ],
    );
  }

  Widget _buildAttendeeList(List<Attendee> attendees) {
    return ProListView(
      height: 200,
      listItems: attendees
          .map((attendee) => ListTile(
                leading: ProUserAvatar(user: attendee.user),
                title: ProText(attendee.user.getFirstAndLastName()),
                trailing: Icon(attendee.rsvpStatus.getDisplayInfo().$1),
              ))
          .toList(),
    );
  }

  List<ProUserComment> _buildComments(Event event) {
    event.comments?.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return event.comments
            ?.map((comment) => ProUserComment(
                comment: comment, hideNames: event.isGuestListHidden))
            .toList() ??
        [];
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    ref.watch(eventProvider);
    return FutureBuilder(
        future: findEventWithId(widget.eventId!),
        builder: (context, AsyncSnapshot<Event?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              event == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            event = snapshot.data!;
            return _buildEvent(context, event, ref);
          }
          return Scaffold(
            // appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProText('Error loading event ${snapshot.error}',
                      maxLines: 20),
                  ProOutlinedButton(
                      onPressed: () => context.go('/'),
                      child: ProText('Go Home')),
                ],
              ),
            ),
          );
        });
  }
}
