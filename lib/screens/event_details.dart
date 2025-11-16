import 'dart:async';
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
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/resources.dart';
import 'package:merrymakin/commons/service/cookie_service.dart';
import 'package:merrymakin/commons/utils/colors.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_outlined_button.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_stacked_fab.dart';
import 'package:merrymakin/commons/widgets/cards/pro_card.dart';
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
  List<Color> _gradientColors = [Colors.black, Colors.black, Colors.black];
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;


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
      bottom: generalAppLevelPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProText(
            receivedEvent.name,
            color: Colors.white,
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
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
            maxLines: 3,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: generalAppLevelPadding / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              ProText(
                receivedEvent.formattedStartDateTime,
                color: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (receivedEvent.location != null && receivedEvent.location!.isNotEmpty) ...[
          SizedBox(height: generalAppLevelPadding / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              ProText(
                receivedEvent.location!,
                color: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]],
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

  Gradient _buildHeroGradient(receivedEvent) {
    // Apply gradient only at the bottom 25% of the image for text readability
    // Keep the rest of the image completely transparent and visible
    if (_gradientColors.length >= 3) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          _gradientColors[1].withOpacity(0.1),
          _gradientColors[1].withOpacity(0.4),
          _gradientColors[2].withOpacity(0.9),
          _gradientColors[2].withOpacity(1),
        ],
        stops: const [0.55, 0.55, 0.6, 0.8, 1.0],
      );
    } else if (_gradientColors.length == 2) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.transparent,
          _gradientColors[0].withOpacity(0.3),
          _gradientColors[1].withOpacity(0.6),
          _gradientColors[1].withOpacity(0.75),
        ],
        stops: const [0.0, 0.75, 0.8, 0.9, 0.95, 1.0],
      );
    } else {
      // Fallback to single color
      final gradientColor = _gradientColor ?? Colors.black;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.transparent,
          gradientColor.withOpacity(0.4),
          gradientColor.withOpacity(0.6),
          gradientColor.withOpacity(0.75),
        ],
        stops: const [0.0, 0.75, 0.7, 0.9, 0.95, 1.0],
      );
    }
  }

  Gradient _buildFullScreenGradient() {
    // Background gradient starts with same colors as hero overlay gradient at bottom
    // Then continues to evolve after the image area for seamless blending
    if (_gradientColors.length >= 3) {
      // Start with hero gradient's bottom colors, then evolve
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _gradientColors[1].withOpacity(0.4), // Match hero gradient at 0.75 stop
          _gradientColors[2].withOpacity(0.9), // Match hero gradient at 0.8 stop
          _gradientColors[2].withOpacity(1), // Match hero gradient at 1.0 stop (seamless transition)
          _gradientColors[2].withOpacity(0.95), // Continue evolving
          _gradientColors[1].withOpacity(0.9), // Transition to second color
          // _gradientColors[0].withOpacity(0.9), // Loop back - first color at bottom
        ],
        stops: const [0.0, 0.05, 0.1, 0.85, 1.0],
      );
    } else if (_gradientColors.length == 2) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _gradientColors[0].withOpacity(0.3), // Match hero gradient at 0.9 stop
          _gradientColors[1].withOpacity(0.6), // Match hero gradient at 0.95 stop
          _gradientColors[1].withOpacity(0.75), // Match hero gradient at 1.0 stop (seamless transition)
          _gradientColors[1].withOpacity(0.85), // Continue evolving
          _gradientColors[1].withOpacity(0.9),
          _gradientColors[0].withOpacity(0.85), // Transition to first color
          _gradientColors[0].withOpacity(0.9), // Loop back - first color at bottom
        ],
        stops: const [0.0, 0.05, 0.1, 0.3, 0.5, 0.75, 1.0],
      );
    } else {
      // Fallback to single color - match hero gradient then evolve
      final gradientColor = _gradientColor ?? Colors.black;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientColor.withOpacity(0.4), // Match hero gradient at 0.9 stop
          gradientColor.withOpacity(0.6), // Match hero gradient at 0.95 stop
          gradientColor.withOpacity(0.75), // Match hero gradient at 1.0 stop (seamless transition)
          gradientColor.withOpacity(0.85), // Continue evolving
          gradientColor.withOpacity(0.92),
          gradientColor.withOpacity(0.95), // Loop back at bottom
        ],
        stops: const [0.0, 0.05, 0.1, 0.4, 0.7, 1.0],
      );
    }
  }

  Widget buildHeroImageAndContent(receivedEvent, height, width) {
    return // Event image with gradient and overlay
        SizedBox(
      height: height,
      width: width,
      child: Transform.scale(
        scale: 1.0 + (_scrollOffset.abs() / height).clamp(0.0, 0.5),
        alignment: Alignment.bottomCenter,
        child: Stack(
          fit: StackFit.expand,
          children: [
            buildEventImage(receivedEvent),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: _buildHeroGradient(receivedEvent),
                ),
              ),
            ),
            buildNameAndTimeOverlay(receivedEvent),
          ],
        ),
      ),
    );
  }

  Widget buildEventDetails(receivedEvent, constraints) {
    return Padding(
      padding: const EdgeInsets.only(
          left: generalAppLevelPadding, right: generalAppLevelPadding),
      child: ProCard(
        elevation: 10,
        surfaceTintColor: Colors.white.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ProText('Hosted by ', textStyle: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    ...receivedEvent.hosts
                        .map((final User host) =>
                            ProUserAvatar(user: host, radius: 20))
                        .toList()
                  ],
                ),
              ],
            ),
            const SizedBox(height: generalAppLevelPadding),      
            
            ProText(
              textAlign: TextAlign.center,
              receivedEvent.description!,
              textStyle: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

    LinearGradient _buildGradient(Color gradientColor) {
    return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            gradientColor.withOpacity(0.3),
            gradientColor.withOpacity(0.7),
            gradientColor.withOpacity(0.85),
          ],
          stops: const [0.0, 0.5, 0.7, 0.85, 1.0],
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
                backgroundColor: _gradientColor ?? Colors.black,
                body: Container(
                  decoration: BoxDecoration(
                    gradient: _buildFullScreenGradient(),
                  ),
                  child: Stack(children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          buildHeroImageAndContent(
                              receivedEvent, height * 0.7, width),
                          const SizedBox(height: generalAppLevelPadding),
                          if (receivedEvent.description != null &&
                              receivedEvent.description != "")
                            buildEventDetails(receivedEvent, constraints),
                          // Event content
                          Padding(
                            padding: const EdgeInsets.only(
                                left: generalAppLevelPadding,
                                right: generalAppLevelPadding,
                                top: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // _buildEventInformation(
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
                                SizedBox(height: generalAppLevelPadding),
                                
                              ],
                            ),
                          ),
                          buildCommentSection(receivedEvent),
                                SizedBox(height: generalAppLevelPadding * 10),
                        ],
                      ),
                    ),
                    buildNavigationButtons(receivedEvent),
                  ]),
                ),
                floatingActionButton: receivedEvent
                        .isHostedByMe(cookiesService.locallyAvailableUserInfo)
                    ? buildActionButtonForHosts(context, receivedEvent)
                    // : buildActionButtonForGuests(context, receivedEvent, ref),
                    : null),
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

  Widget _buildRsvpButtons(Event event) {
    RSVPStatus rsvpStatus =
        event.getRsvpStatusForUser(cookiesService.locallyAvailableUserInfo);
    return Row(
      children: [
        IconButton(
            isSelected: rsvpStatus == RSVPStatus.GOING,
            icon: Icon(RSVPStatus.GOING.getDisplayInfo().$1),
            // text: RSVPStatus.GOING.getDisplayInfo().$2,
            onPressed: () {
              rsvpForEvent(event, RSVPStatus.GOING,
                      cookiesService.locallyAvailableUserInfo)
                  .then((value) {
                ref.read(eventProvider.notifier).updateEvent(event);
              }).onError((error, stackTrace) =>
                      showSnackBar(context, error.toString()));
            }),
        IconButton(
            isSelected: rsvpStatus == RSVPStatus.MAYBE,
            icon: Icon(RSVPStatus.MAYBE.getDisplayInfo().$1),
            // text: RSVPStatus.MAYBE.getDisplayInfo().$2,
            onPressed: () {
              rsvpForEvent(event, RSVPStatus.MAYBE,
                  cookiesService.locallyAvailableUserInfo);
              ref.read(eventProvider.notifier).updateEvent(event);
            }),
        IconButton(
            isSelected: rsvpStatus == RSVPStatus.NOT_GOING,
            icon: Icon(RSVPStatus.NOT_GOING.getDisplayInfo().$1),
            // text: RSVPStatus.NOT_GOING.getDisplayInfo().$2,
            onPressed: () {
              rsvpForEvent(event, RSVPStatus.NOT_GOING,
                  cookiesService.locallyAvailableUserInfo);
              ref.read(eventProvider.notifier).updateEvent(event);
            })
      ],
    );
  }

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

  Widget buildCommentSection(Event receivedEvent) {
    return Padding(
      padding: const EdgeInsets.only(
                              left: generalAppLevelPadding,
                              right: generalAppLevelPadding,
                              top: generalAppLevelPadding),
      child: ProCard(
        elevation: 10,
        surfaceTintColor: Colors.white.withOpacity(0.1),
          child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProText(
              'Comments',
              textStyle: const TextStyle(
                fontSize: 24,
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
                          addCommentToEvent(receivedEvent, comment, context)
                              .whenComplete(() {
                            ref
                                .read(eventProvider.notifier)
                                .updateEvent(receivedEvent);
                          });
                        },
                        user: cookiesService.locallyAvailableUserInfo));
              },
              child: ProText('Comment'),
            ),
          ],
        ),
        if (receivedEvent.comments != null && receivedEvent.comments!.isNotEmpty)
          ..._buildComments(receivedEvent, cookiesService.currentJwtToken == null),
        if (receivedEvent.comments == null || receivedEvent.comments!.isEmpty)
          SizedBox(height: 200, child: Center(child: const ProText(textStyle: TextStyle(fontSize: 16,), 'Be the first to break the silence! 🎤'))),
        // const SizedBox(height: 200),
      ])),
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
      // Extract multiple colors for gradient
      extractMultipleColorsFromImage(eventData.imageUrl, mounted, colorCount: 3).then((colors) {
        setState(() {
          _gradientColors = colors;
          _gradientColor = colors.isNotEmpty ? colors.last : Colors.black;
        });
      });
      // Also extract single color for backward compatibility
      extractGradientFromImage(eventData.imageUrl, mounted).then((value) {
        setState(() {
          _gradientColor = value;
        });
      });
    } else {
      setState(() {
        _gradientColor = Colors.black;
        _gradientColors = [Colors.black, Colors.black, Colors.black];
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
