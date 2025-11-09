import 'dart:async';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/country_currency.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/event_attendee.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/models/spryly_services.dart';
import 'package:merrymakin/commons/resources.dart';
import 'package:merrymakin/commons/service/cookie_service.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_outlined_button.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_stacked_fab.dart';
import 'package:merrymakin/commons/widgets/oauth_login.dart';
import 'package:merrymakin/commons/widgets/pro_add_comment.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:merrymakin/commons/widgets/pro_font_selector.dart';
import 'package:merrymakin/commons/widgets/pro_list_view.dart';
import 'package:merrymakin/commons/widgets/pro_scaffold.dart';
import 'package:merrymakin/commons/widgets/pro_snackbar.dart';
import 'package:merrymakin/commons/widgets/pro_tab_view.dart';
import 'package:merrymakin/commons/widgets/pro_theme_effects.dart';
import 'package:merrymakin/commons/widgets/pro_user_avatar.dart';
import 'package:merrymakin/factory/app_factory.dart';
import 'package:merrymakin/providers/events_provider.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/service/event_service.dart';
import 'package:merrymakin/commons/utils/platform_web.dart'
    if (dart.library.io) 'package:merrymakin/commons/utils/platform_stub.dart'
    as platform;
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
  CookiesService cookiesService = AppFactory().cookiesService;
  Color? _gradientColor;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  Future<void> _extractColorFromImage(String imageUrl) async {
    if (imageUrl.isEmpty) {
      setState(() {
        _gradientColor = Colors.black;
      });
      return;
    }

    try {
      final imageProvider = NetworkImage(imageUrl);
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);

      final completer = Completer<ui.Image?>();
      late ImageStreamListener listener;

      listener = ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          completer.complete(info.image);
          imageStream.removeListener(listener);
        },
        onError: (exception, stackTrace) {
          completer.complete(null);
          imageStream.removeListener(listener);
        },
      );

      imageStream.addListener(listener);
      final image = await completer.future;

      if (image != null && mounted) {
        final pixelData =
            await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (pixelData != null) {
          final bytes = pixelData.buffer.asUint8List();
          final width = image.width;
          final height = image.height;

          // Sample from bottom 30% of the image where text will be positioned
          final sampleStartY = (height * 0.7).toInt();
          final sampleEndY = height;

          int totalR = 0, totalG = 0, totalB = 0;
          int sampleCount = 0;

          // Sample pixels in the bottom portion
          for (int y = sampleStartY; y < sampleEndY; y += 2) {
            for (int x = 0; x < width; x += 2) {
              final index = (y * width + x) * 4;
              if (index + 3 < bytes.length) {
                totalR += bytes[index];
                totalG += bytes[index + 1];
                totalB += bytes[index + 2];
                sampleCount++;
              }
            }
          }

          if (sampleCount > 0 && mounted) {
            // Darken the color slightly to ensure text readability
            final avgR = (totalR / sampleCount).round();
            final avgG = (totalG / sampleCount).round();
            final avgB = (totalB / sampleCount).round();

            setState(() {
              _gradientColor = Color.fromRGBO(
                (avgR * 0.7).round().clamp(0, 255),
                (avgG * 0.7).round().clamp(0, 255),
                (avgB * 0.7).round().clamp(0, 255),
                1.0,
              );
            });
          }
        }
      }
    } catch (e) {
      // If extraction fails, use default dark color
      if (mounted) {
        setState(() {
          _gradientColor = Colors.black;
        });
      }
    }
  }

  LinearGradient _buildBottomGradient(Color gradientColor) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.transparent,
        gradientColor.withOpacity(0.3),
        gradientColor.withOpacity(0.7),
      ],
      stops: const [0.0, 0.5, 0.75, 1.0],
    );
  }

  List<Widget> _buildInfoRow(IconData? icon, Widget content) {
    return [
      const SizedBox(height: generalAppLevelPadding),
      Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 8)
          ],
          content,
        ],
      )
    ];
  }

  void _showOptionsModal(BuildContext context, Event event) {
    final String eventType =
        event.subEvents != null && event.subEvents!.isNotEmpty
            ? "Celebration"
            : "Event";
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
                      .isHostedByMe(cookiesService.locallyAvailableUserInfo)) {
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
    // Time is now displayed on the image overlay, so don't show it here
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

  Widget buildNavigationButtons(receivedEvent) {
// Back button and menu actions overlay
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              left: generalAppLevelPadding / 2,
              right: generalAppLevelPadding / 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
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
              if (receivedEvent
                  .isHostedByMe(cookiesService.locallyAvailableUserInfo))
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius:
                        BorderRadius.circular(generalAppLevelPadding * 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onPressed: () => _showOptionsModal(context, receivedEvent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNameAndTimeOverlay(receivedEvent) {
    // Event name and time overlay
    return Positioned(
      left: generalAppLevelPadding,
      right: generalAppLevelPadding,
      bottom: generalAppLevelPadding * 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProText(
            receivedEvent.name,
            textStyle: TextStyle(
              fontFamily: receivedEvent.font != null
                  ? ProFontType.values
                      .firstWhere(
                        (type) => type.toString() == receivedEvent.font,
                        orElse: () => ProFontType.system,
                      )
                      .fontFamily
                  : null,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
            maxLines: 3,
            textAlign: TextAlign.center,
          ),
          if (receivedEvent.subEvents == null ||
              receivedEvent.subEvents!.isEmpty) ...[
            // const SizedBox(height: generalAppLevelPadding / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                ProText(
                  receivedEvent.formattedStartDateTime,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildEventImage(receivedEvent) {
    return ClipRRect(
      child: CachedNetworkImage(
        imageUrl: receivedEvent.imageUrl,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget buildHeroImageAndContent(receivedEvent, height, width) {
    return // Event image with gradient and overlay
        SizedBox(
      height: height,
      width: width,
      child: Transform.scale(
        scale: 1.0 +
            (_scrollOffset.abs() /height)
                .clamp(0.0, 0.5),
        alignment: Alignment.bottomCenter,
        child: Stack(
          fit: StackFit.expand,
          children: [
            buildEventImage(receivedEvent),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: _buildBottomGradient(
                    _gradientColor ?? Colors.black,
                  ),
                ),
              ),
            ),
            buildNameAndTimeOverlay(receivedEvent),
          ],
        ),
      ),
    );
  }

  Widget _buildEvent(
      BuildContext context, final Event? receivedEvent, WidgetRef ref) {
    if (receivedEvent == null) {
      showSnackBar(context, 'Event not found');
      return ProScaffold(
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double height = constraints.maxHeight;
          final double width = constraints.maxWidth;
          return ProThemeEffects(
            themeType: themeType,
            effectType: effectType,
            size: Size(width, height),
            child: ProScaffold(
              iosAppLink: IOS_APP_STORE_LINK,
              body: Stack(children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      buildHeroImageAndContent(receivedEvent, height * 0.8, width),
                      // Event content
                      Padding(
                        padding: const EdgeInsets.only(
                            left: generalAppLevelPadding,
                            right: generalAppLevelPadding,
                            top: generalAppLevelPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEventInformation(
                                receivedEvent, constraints.maxWidth),
                            ..._buildInfoRow(
                              Icons.star,
                              Row(
                                children: [
                                  const ProText('Hosted by '),
                                  Row(
                                    children: receivedEvent.hosts
                                        .map(
                                            (host) => ProUserAvatar(user: host))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            if (receivedEvent.description != null &&
                                receivedEvent.description != "") ...[
                              const SizedBox(height: generalAppLevelPadding),
                              ProText(
                                receivedEvent.description!,
                                textStyle: const TextStyle(
                                  height: 1.5,
                                ),
                                maxLines: 5,
                              ),
                            ],
                            if (receivedEvent.attendees != null &&
                                receivedEvent
                                        .getAttendeesByRsvpStatus(
                                            RSVPStatus.GOING)
                                        .length >
                                    0 &&
                                receivedEvent
                                        .getAttendeesByRsvpStatus(
                                            RSVPStatus.MAYBE)
                                        .length >
                                    0 &&
                                !receivedEvent.isGuestListHidden) ...[
                              const SizedBox(
                                  height: generalAppLevelPadding * 1.5),
                              _buildGuestList(receivedEvent, context),
                            ],
                            ...[
                              const SizedBox(
                                  height: generalAppLevelPadding / 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                              onUpdate:
                                                  (final Comment comment) {
                                                if (receivedEvent.comments ==
                                                    null) {
                                                  receivedEvent.comments = [];
                                                }
                                                // add comment to top of event.comments
                                                receivedEvent.comments!
                                                    .add(comment);
                                                addCommentToEvent(receivedEvent,
                                                        comment, context)
                                                    .whenComplete(() {
                                                  ref
                                                      .read(eventProvider
                                                          .notifier)
                                                      .updateEvent(
                                                          receivedEvent);
                                                });
                                              },
                                              user: cookiesService
                                                  .locallyAvailableUserInfo));
                                    },
                                    child: ProText('Comment'),
                                  ),
                                ],
                              ),
                              ..._buildComments(receivedEvent,
                                  cookiesService.currentJwtToken == null),
                              const SizedBox(height: 200),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                buildNavigationButtons(receivedEvent),
              ]),
              floatingActionButton: receivedEvent
                      .isHostedByMe(cookiesService.locallyAvailableUserInfo)
                  ? buildActionButtonForHosts(context, receivedEvent)
                  : buildActionButtonForGuests(context, receivedEvent, ref),
            ),
          );
        },
      ),
    );
  }

  Widget buildActionButtonForGuests(
      final BuildContext buildContext, final Event event, WidgetRef ref) {
    if (cookiesService.currentJwtToken == null ||
        cookiesService.currentJwtToken == '') {
      return FloatingActionButton.extended(
        onPressed: () {
          openProBottomModalSheet(
            buildContext,
            OAuthLogin(
              userService: userService,
              sprylyService: SprylyServices.MerryMakin.name,
              onPressedCallback: () {
                context.pop();
                ref.read(eventProvider.notifier).updateEvent(event);
              },
            ),
          );
        },
        foregroundColor: Theme.of(buildContext).colorScheme.surface,
        backgroundColor: Theme.of(buildContext).primaryColor,
        label: const Row(
          children: [
            const Icon(Icons.login),
            const SizedBox(width: 8),
            const ProText('Login to RSVP'),
          ],
        ),
      );
    }
    final RSVPStatus rsvpStatus =
        event.getRsvpStatusForUser(cookiesService.locallyAvailableUserInfo);
    final List<ProStackedFabObject> stackedFabs = [
      if (rsvpStatus != RSVPStatus.GOING)
        ProStackedFabObject(
            icon: RSVPStatus.GOING.getDisplayInfo().$1,
            title: RSVPStatus.GOING.getDisplayInfo().$2,
            onTap: () {
              rsvpForEvent(event, RSVPStatus.GOING,
                      cookiesService.locallyAvailableUserInfo)
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
                  cookiesService.locallyAvailableUserInfo);
              ref.read(eventProvider.notifier).updateEvent(event);
            }),
      if (rsvpStatus != RSVPStatus.NOT_GOING)
        ProStackedFabObject(
            icon: RSVPStatus.NOT_GOING.getDisplayInfo().$1,
            title: RSVPStatus.NOT_GOING.getDisplayInfo().$2,
            onTap: () {
              rsvpForEvent(event, RSVPStatus.NOT_GOING,
                  cookiesService.locallyAvailableUserInfo);
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
              openProBottomModalSheet(
                  context,
                  ProShareSheet(
                    message: 'RSVP to ${event.name}!',
                    link: 'https://merrymakin.com/${event.id}',
                    userService: userService,
                    onShare: () {
                      context.pop();
                    },
                    event: event,
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

  // Widget _buildRsvpButtons(Event event) {
  //   RSVPStatus rsvpStatus =
  //       event.getRsvpStatusForUser(cookiesService.locallyAvailableUserInfo);
  //   return Row(
  //     children: [
  //       if (rsvpStatus != RSVPStatus.GOING)
  //         IconButton(
  //             icon: Icon(RSVPStatus.GOING.getDisplayInfo().$1),
  //             // text: RSVPStatus.GOING.getDisplayInfo().$2,
  //             onPressed: () {
  //               rsvpForEvent(event, RSVPStatus.GOING,
  //                       cookiesService.locallyAvailableUserInfo)
  //                   .then((value) {
  //                 ref.read(eventProvider.notifier).updateEvent(event);
  //               }).onError((error, stackTrace) =>
  //                       showSnackBar(context, error.toString()));
  //             }),
  //       if (rsvpStatus != RSVPStatus.MAYBE)
  //         IconButton(
  //             icon: Icon(RSVPStatus.MAYBE.getDisplayInfo().$1),
  //             // text: RSVPStatus.MAYBE.getDisplayInfo().$2,
  //             onPressed: () {
  //               rsvpForEvent(event, RSVPStatus.MAYBE,
  //                   cookiesService.locallyAvailableUserInfo);
  //               ref.read(eventProvider.notifier).updateEvent(event);
  //             }),
  //       if (rsvpStatus != RSVPStatus.NOT_GOING)
  //         IconButton(
  //             icon: Icon(RSVPStatus.NOT_GOING.getDisplayInfo().$1),
  //             // text: RSVPStatus.NOT_GOING.getDisplayInfo().$2,
  //             onPressed: () {
  //               rsvpForEvent(event, RSVPStatus.NOT_GOING,
  //                   cookiesService.locallyAvailableUserInfo);
  //               ref.read(eventProvider.notifier).updateEvent(event);
  //             })
  //     ],
  //   );
  // }

  Widget _buildGuestList(Event event, BuildContext buildContext) {
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
                  if (event
                      .isHostedByMe(cookiesService.locallyAvailableUserInfo))
                    const ProText(
                      'Guest List',
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (event.attendees != null &&
                      event.getAttendeesByRsvpStatus(RSVPStatus.GOING).length >
                          0 &&
                      event.getAttendeesByRsvpStatus(RSVPStatus.MAYBE).length >
                          0)
                    ProOutlinedButton(
                        onPressed: () {
                          openProBottomModalSheet(buildContext,
                              _buildAllAttendeesWithStatus(event));
                        },
                        child: ProText('View All')),
                ],
              ),
              if (!event.isGuestCountHidden)
                Row(
                  children: [
                    if (event.attendees != null &&
                        event
                                .getAttendeesByRsvpStatus(RSVPStatus.GOING)
                                .length ==
                            0 &&
                        event
                                .getAttendeesByRsvpStatus(RSVPStatus.MAYBE)
                                .length ==
                            0)
                      Row(
                        children: [
                          SizedBox(height: generalAppLevelPadding),
                          ProText("Don’t party alone! Tap "),
                          Icon(
                            Icons.share,
                            size: 16,
                          ),
                          ProText(" to share the fun!")
                        ],
                      ),
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
        'Can\'t Go (${event.getAttendeesByRsvpStatus(RSVPStatus.NOT_GOING).length})',
        // 'Invited (${event.getAttendeesByRsvpStatus(RSVPStatus.UNDECIDED).length})',
        // 'All (${event.attendees!.length})',
      ],
      children: [
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.GOING)),
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.MAYBE)),
        _buildAttendeeList(
            event.getAttendeesByRsvpStatus(RSVPStatus.NOT_GOING)),
        _buildAttendeeList(
            event.getAttendeesByRsvpStatus(RSVPStatus.UNDECIDED)),
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

  List<ProUserComment> _buildComments(Event event, final bool hideNames) {
    event.comments?.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return event.comments
            ?.map((comment) => ProUserComment(
                comment: comment,
                hideNames: event.isGuestListHidden || hideNames))
            .toList() ??
        [];
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      platform.updateMetaTags(
          event?.name ?? '', event?.description ?? '', event?.imageUrl ?? '');
    }
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.offset < 0) {
          _scrollOffset = _scrollController.offset;
        }
        
      });

      // if (_scrollController.offset <= 0) {
      //   // Prevent the scroll offset from going negative
      //   _scrollController.jumpTo(0);
      // }
    });
  }

  void _initializeGradient(Event? eventData) {
    if (eventData != null && eventData.imageUrl.isNotEmpty) {
      _extractColorFromImage(eventData.imageUrl);
    } else {
      setState(() {
        _gradientColor = Colors.black;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (kIsWeb) {
      // Clean up meta tags when leaving the page
      platform.removeMetaTags();
    }
    super.dispose();
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
            final newEvent = snapshot.data!;
            // Initialize gradient when event is loaded or changed
            if (event == null ||
                event?.id != newEvent.id ||
                event?.imageUrl != newEvent.imageUrl) {
              event = newEvent;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _initializeGradient(event);
                }
              });
            } else {
              event = newEvent;
            }
            return _buildEvent(context, event, ref);
          }
          return ProScaffold(
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
