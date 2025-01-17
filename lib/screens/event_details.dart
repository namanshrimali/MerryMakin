import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/country_currency.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/event_attendee.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/service/cookies_service.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_outlined_button.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_stacked_fab.dart';
import 'package:merrymakin/commons/widgets/pro_add_comment.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:merrymakin/commons/widgets/pro_list_view.dart';
import 'package:merrymakin/commons/widgets/pro_snackbar.dart';
import 'package:merrymakin/commons/widgets/pro_tab_view.dart';
import 'package:merrymakin/commons/widgets/pro_user_avatar.dart';
import 'package:merrymakin/providers/events_provider.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/service/event_service.dart';
import 'package:share_plus/share_plus.dart';
import '../commons/widgets/pro_user_comment.dart';

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
  List<Widget> _buildInfoRow(IconData icon, Widget content) {
    return [
      const SizedBox(height: generalAppLevelPadding),
      Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: content),
        ],
      )
    ];
  }

  void _showOptionsModal(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const ProText('Edit Event'),
                onTap: () {
                  if (!event
                      .isHostedByMe(CookiesService.locallyAvailableUserInfo)) {
                    return;
                  }
                  Navigator.pop(context); // Close the bottom sheet
                  context.push('/events/${event.id}/edit');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const ProText(
                  'Delete Event',
                  textStyle: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  // Close the bottom sheet
                  Navigator.pop(context);

                  // Show confirmation dialog
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const ProText('Delete Event'),
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

  Widget _buildEvent(
      BuildContext context, final Event? receivedEvent, WidgetRef ref) {
    if (receivedEvent == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: ProText('Event not found'),
        ),
      );
    }

    return Scaffold(
        body: LayoutBuilder(builder: (context, constraints) {
          final double height = constraints.maxHeight;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: height * 0.6,
                pinned: true,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius:
                        BorderRadius.circular(generalAppLevelPadding * 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go('/'),
                  ),
                ),
                actions: [
                  if (receivedEvent
                      .isHostedByMe(CookiesService.locallyAvailableUserInfo))
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius:
                            BorderRadius.circular(generalAppLevelPadding * 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.white),
                        onPressed: () =>
                            _showOptionsModal(context, receivedEvent),
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
                      ProText(
                        receivedEvent.name,
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                      ..._buildInfoRow(
                        Icons.access_time,
                        Row(
                          children: [
                            ProText(
                              receivedEvent.formattedStartDateTime,
                            ),
                          ],
                        ),
                      ),
                      ..._buildInfoRow(
                        Icons.star,
                        Row(
                          children: [
                            const ProText('Hosted by '),
                            Expanded(
                              child: SizedBox(
                                height: 24,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: receivedEvent.hosts.length,
                                  itemBuilder: (context, index) {
                                    final host = receivedEvent.hosts[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: ProUserAvatar(
                                        user: host,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: generalAppLevelPadding / 2),
                      if (receivedEvent.location != null &&
                          receivedEvent.location!.isNotEmpty)
                        ..._buildInfoRow(
                          Icons.location_on,
                          ProText(
                            receivedEvent.location!,
                            textStyle: const TextStyle(),
                          ),
                        ),
                      if (receivedEvent.spots != null &&
                          receivedEvent.spots! > 0)
                        ..._buildInfoRow(
                          Icons.person,
                          ProText(
                            '${receivedEvent.spots} spots',
                            textStyle: const TextStyle(),
                          ),
                        ),
                      if (receivedEvent.costPerSpot != null &&
                          receivedEvent.costPerSpot! > 0) ...[
                        ..._buildInfoRow(
                          Icons.loyalty,
                          ProText(
                            '${receivedEvent.countryCurrency!.getCurrencySymbol()}${receivedEvent.costPerSpot} per person',
                            textStyle: const TextStyle(),
                          ),
                        ),
                      ],
                      if (receivedEvent.dressCode != null &&
                          receivedEvent.dressCode!.isNotEmpty)
                        ..._buildInfoRow(
                          Icons.style,
                          ProText(
                            receivedEvent.dressCode!,
                            textStyle: const TextStyle(),
                          ),
                        ),
                      if (receivedEvent.foodSituation != null &&
                          receivedEvent.foodSituation!.isNotEmpty)
                        ..._buildInfoRow(
                          Icons.dining,
                          ProText(
                            receivedEvent.foodSituation!,
                            textStyle: const TextStyle(),
                          ),
                        ),
                      if (receivedEvent.description != null) ...[
                        const SizedBox(height: generalAppLevelPadding),
                        ProText(
                          receivedEvent.description!,
                          textStyle: const TextStyle(
                            height: 1.5,
                          ),
                          maxLines: null,
                        ),
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
                              text: 'Comment',
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

                                          ;
                                        },
                                        user: CookiesService
                                            .locallyAvailableUserInfo));
                              },
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
        floatingActionButton:
            receivedEvent.isHostedByMe(CookiesService.locallyAvailableUserInfo)
                ? buildActionButtonForHosts(context, receivedEvent)
                : buildActionButtonForGuests(context, receivedEvent, ref));
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
        buttonForegroundColor: Theme.of(buildContext).scaffoldBackgroundColor,
        buttonBackgroundColor: Theme.of(buildContext).primaryColor,
      );
    }

    // Show RSVP stacked fab for non-attendees

    return ProStackedFab(
      fabObjects: stackedFabs,
      buttonText: const ProText('RSVP'),
    );
  }

  Widget buildActionButtonForHosts(BuildContext context, Event event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Guests count button
          FloatingActionButton.extended(
            heroTag: 'attendees',
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).scaffoldBackgroundColor,
            onPressed: () {
              openProBottomModalSheet(
                  context, _buildAllAttendeesWithStatus(event));
            },
            label: Row(
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 8),
                ProText(
                    '${event.getAttendeesByRsvpStatus(RSVPStatus.GOING).length} Going'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Share button
          FloatingActionButton(
            heroTag: 'share',
            onPressed: () {
              String shareMessage =
                  'RSVP to ${event.name}. http://merrymakin.com/${event.id}\n';

              if (event.startDateTime != null) {
                shareMessage +=
                    'When: ${_formatDateTime(event.startDateTime!, event.endDateTime)}\n';
              }
              Share.share(shareMessage,
                  sharePositionOrigin:
                      Rect.fromPoints(const Offset(2, 2), const Offset(3, 3)));
            },
            child: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime start, DateTime? end) {
    final startDate = DateFormat('EEE, MMM d').format(start);
    final startTime = DateFormat('h:mm a').format(start);
    if (end != null) {
      final endTime = DateFormat('h:mm a').format(end);
      return '$startDate · $startTime - $endTime';
    }
    return '$startDate · $startTime';
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
                      text: 'View All'),
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
        'All (${event.attendees!.length})',
        'Going (${event.getAttendeesByRsvpStatus(RSVPStatus.GOING).length})',
        'Maybe (${event.getAttendeesByRsvpStatus(RSVPStatus.MAYBE).length})',
        'Not Going (${event.getAttendeesByRsvpStatus(RSVPStatus.NOT_GOING).length})',
      ],
      children: [
        _buildAttendeeList(event.attendees!),
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.GOING)),
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.MAYBE)),
        _buildAttendeeList(
            event.getAttendeesByRsvpStatus(RSVPStatus.NOT_GOING)),
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
          event = snapshot.data!;
          return _buildEvent(context, snapshot.data!, ref);
        });
  }
}
