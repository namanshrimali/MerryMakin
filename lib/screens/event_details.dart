import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/crud_operation.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/event_attendee.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/resources.dart';
import 'package:merrymakin/commons/service/cookie_service.dart';
import 'package:merrymakin/commons/utils/colors.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_outlined_button.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_segmented_button.dart';
import 'package:merrymakin/commons/widgets/cards/pro_card.dart';
import 'package:merrymakin/commons/widgets/celebrations/pro_celebration_overlay.dart';
import 'package:merrymakin/commons/widgets/celebrations/celebration_animations.dart';
import 'package:merrymakin/commons/widgets/pro_add_comment.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:merrymakin/commons/widgets/pro_font_selector.dart';
import 'package:merrymakin/commons/widgets/pro_list_item.dart';
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
import 'dart:io';

import 'package:merrymakin/commons/utils/platform_web.dart'
    if (dart.library.io) 'package:merrymakin/commons/utils/platform_stub.dart'
    as platform;
import 'package:merrymakin/utils/event_gradient_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../commons/widgets/buttons/pro_primary_button.dart';
import '../commons/widgets/pro_user_comment.dart';
import '../commons/themes/pro_themes.dart';
import '../commons/widgets/pro_share_sheet.dart';
import '../widgets/rsvp_modal.dart';

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
  late Future<Event?> _eventFuture;
  Event? event;
  ThemeData? eventTheme;
  ProThemeType themeType = ProThemeType.midnight;
  ProEffectType effectType = ProEffectType.none;
  CookiesService cookiesService = AppFactory().cookiesService;
  Color? _gradientColor;
  List<Color> _gradientColors = [Colors.black, Colors.black, Colors.black];
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffsetNotifier =
      ValueNotifier<double>(0.0);
  final GlobalKey<ProCelebrationOverlayState> _celebrationKey = GlobalKey();
  CelebrationConfig? _cachedCelebrationConfig;
  double _heroImageHeight =
      0.6; // should be between 0.5 and 0.9 for gradients to work properly
  Future<void> _openAppleMaps(String location) async {
    final encodedLocation = Uri.encodeComponent(location);
    // Try the native app first, fallback to web
    final Uri nativeUrl =
        Uri.parse('maps://maps.apple.com/?q=$encodedLocation');
    final Uri webUrl = Uri.parse('http://maps.apple.com/?q=$encodedLocation');

    if (await canLaunchUrl(nativeUrl)) {
      await launchUrl(nativeUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showSnackBar(context, 'Could not open Apple Maps');
      }
    }
  }

  Future<void> _openGoogleMaps(String location) async {
    final encodedLocation = Uri.encodeComponent(location);
    // Try the native app first, fallback to web
    final Uri nativeUrl = Uri.parse('comgooglemaps://?q=$encodedLocation');
    final Uri webUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedLocation');

    if (await canLaunchUrl(nativeUrl)) {
      await launchUrl(nativeUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showSnackBar(context, 'Could not open Google Maps');
      }
    }
  }

  bool _isIOSPlatform() {
    if (kIsWeb) {
      return platform.isIOS();
    } else {
      return Platform.isIOS;
    }
  }

  void _showLocationOptionsModal(BuildContext context, Event event) {
    final bool isIOS = _isIOSPlatform();
    openProBottomModalSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.location != null && event.location!.isNotEmpty) ...[
            if (isIOS)
              ProListItem(
                key: Key("apple-maps-${event.id}"),
                leading: const Icon(Icons.map),
                title: const ProText('Open in Apple Maps'),
                onTap: () {
                  Navigator.pop(context);
                  _openAppleMaps(event.location!);
                },
              ),
            if (isIOS) const Divider(),
            ProListItem(
              key: Key("google-maps-${event.id}"),
              leading: const Icon(Icons.map_outlined),
              title: const ProText('Open in Google Maps'),
              onTap: () {
                Navigator.pop(context);
                _openGoogleMaps(event.location!);
              },
            ),
            const Divider(),
            ProListItem(
              key: Key("copy-location-${event.id}"),
              leading: const Icon(Icons.copy),
              title: const ProText('Copy Location'),
              onTap: () {
                Navigator.pop(context);
                showSnackBar(context, 'Location copied to clipboard');
                Clipboard.setData(ClipboardData(text: event.location!));
              },
            ),
          ],
        ],
      ),
      theme: eventTheme,
      themeType: themeType,
      gradientColors: _gradientColors,
    );
  }

  void _showOptionsModal(BuildContext context, Event event) {
    final String eventType =
        event.subEvents != null && event.subEvents!.isNotEmpty
            ? "Celebration"
            : "Event";
    openProBottomModalSheet(
      context,
      Column(
        children: [
          ProListItem(
            key: Key("edit-${event.id}"),
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
          const Divider(),
          ProListItem(
            key: Key("delete-${event.id}"),
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
                            ref.read(eventProvider.notifier).updateEvent(event);
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
      theme: eventTheme,
      themeType: themeType,
      gradientColors: _gradientColors,
    );
  }

  void _shareEvent(Event event, BuildContext eventContext) {
    openProBottomModalSheet(
      eventContext,
      ProShareSheet(
        message: 'RSVP to ${event.name}!',
        link: 'https://merrymakin.com/${event.id}',
        userService: userService,
        onShare: (value) {
          showSnackBar(context, value);
        },
        event: event,
        themeType: themeType,
        effectType: effectType,
      ),
      theme: eventTheme,
      themeType: themeType,
      gradientColors: _gradientColors,
    );
  }

  Widget buildNavigationButtons(receivedEvent, eventContext) {
// Back button and menu actions overlay
    return Positioned(
      top: generalAppLevelPadding,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              left: generalAppLevelPadding / 2,
              right: generalAppLevelPadding / 2),
          child: Row(
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
              const Spacer(),
              ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius:
                        BorderRadius.circular(generalAppLevelPadding * 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.ios_share, color: Colors.white),
                    onPressed: () => _shareEvent(
                      receivedEvent,
                      eventContext,
                    ),
                  ),
                ),
              ],
              if (receivedEvent
                  .isHostedByMe(cookiesService.locallyAvailableUserInfo)) ...[
                const SizedBox(width: generalAppLevelPadding / 2),
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
              fontSize: 36,
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
          SizedBox(height: generalAppLevelPadding / 8),
          ProText(
            receivedEvent.formattedStartDateTime,
            color: Colors.white,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          if (receivedEvent.location != null &&
              receivedEvent.location!.isNotEmpty) ...[
            SizedBox(height: generalAppLevelPadding / 8),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () =>
                  _showLocationOptionsModal(context, receivedEvent),
              child: ProText(
                receivedEvent.location!,
                color: Colors.white,
                textStyle: const TextStyle(fontSize: 18, shadows: [
                  Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26)
                ]),
              ),
            ),
          ]
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
      child: ValueListenableBuilder<double>(
        valueListenable: _scrollOffsetNotifier,
        builder: (context, scrollOffset, child) {
          return Transform.scale(
            scale: 1.0 + (scrollOffset.abs() / height).clamp(0.0, 0.5),
            alignment: Alignment.bottomCenter,
            child: Stack(
              fit: StackFit.expand,
              children: [
                buildEventImage(receivedEvent),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: buildHeroGradient(_gradientColors),
                    ),
                  ),
                ),
                buildNameAndTimeOverlay(receivedEvent),
              ],
            ),
          );
        },
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

  Widget buildRSVPButtonsSection(Event receivedEvent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
      child: _buildRsvpButtons(receivedEvent),
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

        // Update cached celebration config if theme changed
        _cachedCelebrationConfig = CelebrationConfig.forRsvpStatus(
          RSVPStatus.GOING,
          themeType,
        );
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
              body: ProCelebrationOverlay(
                key: _celebrationKey,
                config: _cachedCelebrationConfig ??
                    CelebrationConfig.forRsvpStatus(
                      RSVPStatus.GOING,
                      themeType,
                    ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: buildFullScreenGradient(_gradientColors),
                  ),
                  clipBehavior: Clip.none,
                  child: Stack(clipBehavior: Clip.none, children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          buildHeroImageAndContent(
                              receivedEvent, height * _heroImageHeight, width),
                          const SizedBox(height: generalAppLevelPadding),
                          // Inline RSVP options for guests (non-hosts)
                          if (!receivedEvent.isHostedByMe(
                              cookiesService.locallyAvailableUserInfo)) ...[
                            buildRSVPButtonsSection(receivedEvent),
                            const SizedBox(height: generalAppLevelPadding),
                          ],
                          // if (receivedEvent.isHostedByMe(
                          //     cookiesService.locallyAvailableUserInfo))
                          //   ...[
                          //     _buildHostActionButtons(receivedEvent),
                          //     const SizedBox(height: generalAppLevelPadding),
                          //   ],
                          if (receivedEvent.description != null &&
                              receivedEvent.description != "") ...[
                            buildEventDetails(receivedEvent, constraints),
                            const SizedBox(height: generalAppLevelPadding),
                          ],

                          _buildGuestList(receivedEvent, context, constraints),
                          buildCommentSection(receivedEvent),
                          SizedBox(height: generalAppLevelPadding * 10),
                        ],
                      ),
                    ),
                    buildNavigationButtons(receivedEvent, context),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildActionButtonForHosts(BuildContext context, Event event) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'share',
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.colorScheme.surface,
            onPressed: () {
              _shareEvent(event, context);
            },
            child: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }

  Widget _buildHostActionButtons(Event event) {
    return Padding(
      padding: const EdgeInsets.only(
          left: generalAppLevelPadding, right: generalAppLevelPadding),
      child: ProCard(
        elevation: 10,
        surfaceTintColor: Colors.white.withOpacity(0.1),
        child: Column(
          children: [
            ProText('Host Actions'),
          ],
        ),
      ),
    );
  }

  Widget _buildRsvpButtons(Event event) {
    RSVPStatus rsvpStatus =
        event.getRsvpStatusForUser(cookiesService.locallyAvailableUserInfo);
    return ProCard(
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: ProSegmentedButton(
          backgroundColor: Colors.white.withOpacity(0.1),
          selectedBackgroundColor:
              ProThemes.themes[themeType]?.theme.colorScheme.primary,
          selectedTextColor:
              ProThemes.themes[themeType]?.theme.colorScheme.onPrimary,
          segments: [
            ProButtonSegment(
                icon: Icon(RSVPStatus.GOING.getDisplayInfo().$1),
                value: RSVPStatus.GOING,
                label: ProText(RSVPStatus.GOING.getDisplayInfo().$2)),
            ProButtonSegment(
                icon: Icon(RSVPStatus.NOT_GOING.getDisplayInfo().$1),
                value: RSVPStatus.NOT_GOING,
                label: ProText(RSVPStatus.NOT_GOING.getDisplayInfo().$2)),
            ProButtonSegment(
                icon: Icon(RSVPStatus.MAYBE.getDisplayInfo().$1),
                value: RSVPStatus.MAYBE,
                label: ProText(RSVPStatus.MAYBE.getDisplayInfo().$2)),
          ],
          selected: {rsvpStatus},
          onSelectionChanged: (selected) async {
            // Open RSVP modal instead of directly RSVPing
            await openProBottomModalSheet(
              isFullScreen: true,
              context,
              RsvpModal(
                event: event,
                initialRsvpStatus: selected.first,
                user: cookiesService.locallyAvailableUserInfo,
                themeType: themeType,
              ),
              theme: eventTheme,
              themeType: themeType,
              gradientColors: _gradientColors,
            );
          }),
    );
  }

  Widget _buildGuestList(Event event, BuildContext buildContext, constraints) {
    final goingAttendees =
        event.getAttendeesAndPlusOnesByRsvpStatus(RSVPStatus.GOING);
    final maybeAttendees =
        event.getAttendeesAndPlusOnesByRsvpStatus(RSVPStatus.MAYBE);
    final hasGuests = goingAttendees.isNotEmpty || maybeAttendees.isNotEmpty;
    final totalGuests = goingAttendees.length + maybeAttendees.length;

    return Padding(
      padding: const EdgeInsets.only(
        left: generalAppLevelPadding,
        right: generalAppLevelPadding,
      ),
      child: ProCard(
        elevation: 10,
        surfaceTintColor: Colors.white.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header with title and view all button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ProText(
                  'Guest List',
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasGuests && totalGuests > 0)
                  ProOutlinedButton(
                    onPressed: () {
                      openProBottomModalSheet(
                        buildContext,
                        _buildAllAttendeesWithStatus(event, constraints.maxHeight * 0.4),
                        theme: eventTheme,
                        themeType: themeType,
                        gradientColors: _gradientColors,
                      );
                    },
                    child: ProText('View All'),
                  ),
              ],
            ),
            if (hasGuests) ...[
              Row(
                children: [
                  ProText(
                      'Going ${goingAttendees.length} • Maybe ${maybeAttendees.length}'),
                ],
              ),
            ],
            const SizedBox(height: generalAppLevelPadding),

            // Empty State - Enhanced with fun visuals
            if (!hasGuests && !event.isGuestCountHidden)
              _buildEmptyGuestState(event, buildContext),

            // Guest Sections - Only show if there are guests
            if (hasGuests) ...[
              _buildStackedAvatars(
                  goingAttendees + maybeAttendees,
                  false,
                  0,
                  eventTheme?.colorScheme.primary ??
                      Theme.of(context).colorScheme.primary),
            ] else if (event.isGuestCountHidden && hasGuests) ...[
              // Show avatars but hide counts
              _buildHiddenCountGuestAvatars(goingAttendees, maybeAttendees),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGuestState(Event event, BuildContext buildContext) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: generalAppLevelPadding * 2),
      child: Column(
        children: [
          // Fun icon with animation-ready container
          Container(
            padding: const EdgeInsets.all(generalAppLevelPadding),
            decoration: BoxDecoration(
              color: (ProThemes.themes[themeType]?.theme.colorScheme.primary ??
                      Theme.of(context).colorScheme.primary)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.celebration_rounded,
              size: 48,
              color: ProThemes.themes[themeType]?.theme.colorScheme.primary ??
                  Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: generalAppLevelPadding),
          ProText(
            'No guests yet',
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: generalAppLevelPadding / 2),
          ProText(
            "Don't party alone! Share the fun! 🎉",
            textStyle: TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: generalAppLevelPadding * 1.5),
          ProPrimaryButton(
            ProText("Share Event"),
            onPressed: () {
              openProBottomModalSheet(
                buildContext,
                ProShareSheet(
                  message: 'RSVP to ${event.name}!',
                  link: 'https://merrymakin.com/${event.id}',
                  userService: userService,
                  onShare: (value) {
                    showSnackBar(context, value);
                  },
                  event: event,
                  themeType: themeType,
                  effectType: effectType,
                ),
                theme: eventTheme,
                themeType: themeType,
                gradientColors: _gradientColors,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStackedAvatars(List<Attendee> attendees, bool hasOverflow,
      int overflowCount, Color accentColor) {
    const double avatarRadius = 24.0;
    const double overlap = 8.0;
    const int maxStacked = 5;

    return SizedBox(
      height: avatarRadius * 2 + 4,
      child: Stack(
        children: [
          ...attendees.asMap().entries.take(maxStacked).map((entry) {
            final index = entry.key;
            final attendee = entry.value;
            return Positioned(
              left: index * (avatarRadius * 2 - overlap),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ProUserAvatar(
                  user: attendee.user,
                  radius: avatarRadius,
                ),
              ),
            );
          }),
          if (hasOverflow || attendees.length > maxStacked)
            Positioned(
              left: (attendees.length > maxStacked
                      ? maxStacked
                      : attendees.length) *
                  (avatarRadius * 2 - overlap),
              child: GestureDetector(
                onTap: () {
                  // This will be handled by parent GestureDetector
                },
                child: Container(
                  width: avatarRadius * 2,
                  height: avatarRadius * 2,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor,
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: ProText(
                      '+${hasOverflow ? overflowCount : attendees.length - maxStacked}',
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRowAvatars(List<Attendee> attendees, bool hasOverflow,
      int overflowCount, Color accentColor) {
    const double avatarRadius = 22.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...attendees.map((attendee) => Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withOpacity(0.25),
                    width: 2,
                  ),
                ),
                child: ProUserAvatar(
                  user: attendee.user,
                  radius: avatarRadius,
                ),
              )),
          if (hasOverflow)
            Container(
              width: avatarRadius * 2,
              height: avatarRadius * 2,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: ProText(
                  '+$overflowCount',
                  textStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHiddenCountGuestAvatars(
      List<Attendee> goingAttendees, List<Attendee> maybeAttendees) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          ...goingAttendees.map((attendee) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ProUserAvatar(
                  user: attendee.user,
                  radius: 20,
                ),
              )),
          ...maybeAttendees.map((attendee) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ProUserAvatar(
                  user: attendee.user,
                  radius: 20,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAllAttendeesWithStatus(Event event, double? height) {
    return ProTabView(
      height: height,
      childrenTabTitle: [
        'Going (${event.getAttendeesAndPlusOnesByRsvpStatus(RSVPStatus.GOING).length})',
        'Maybe (${event.getAttendeesAndPlusOnesByRsvpStatus(RSVPStatus.MAYBE).length})',
        'Can\'t Go (${event.getAttendeesAndPlusOnesByRsvpStatus(RSVPStatus.NOT_GOING).length})',
        'Invited (${event.getAttendeesByRsvpStatus(RSVPStatus.UNDECIDED).length})',
        'All (${event.attendees!.length})',
      ],
      children: [
        _buildAttendeeList(
            event.getAttendeesByRsvpStatus(RSVPStatus.GOING), RSVPStatus.GOING),
        _buildAttendeeList(
            event.getAttendeesByRsvpStatus(RSVPStatus.MAYBE), RSVPStatus.MAYBE),
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.NOT_GOING),
            RSVPStatus.NOT_GOING),
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.UNDECIDED),
            RSVPStatus.UNDECIDED),
        _buildAttendeeList(event.attendees!, null),
      ],
    );
  }

  Widget _buildAttendeeList(List<Attendee> attendees, RSVPStatus? status) {
    if (attendees.isEmpty) {
      return _buildEmptyAttendeeState(status);
    }
    return ProListView(
      height: 300,
      listItems: attendees
          .map((attendee) => ListTile(
                leading: ProUserAvatar(user: attendee.user),
                title: ProText(attendee.user.getFirstAndLastName()),
                trailing: Icon(attendee.rsvpStatus.getDisplayInfo().$1),
                subtitle: attendee.plusOnes != null &&
                        attendee.plusOnes!.isNotEmpty
                    ? ProText(
                        "${attendee.plusOnes!.length} Plus Ones: ${attendee.plusOnes!.join(', ')}")
                    : null,
              ))
          .toList(),
    );
  }

  Widget _buildEmptyAttendeeState(RSVPStatus? status) {
    final primaryColor =
        ProThemes.themes[themeType]?.theme.colorScheme.primary ??
            Theme.of(context).colorScheme.primary;

    // Context-aware messaging based on RSVP status
    String title;
    String subtitle;
    IconData icon;
    Color accentColor;

    switch (status) {
      case RSVPStatus.GOING:
        title = 'No one going yet';
        subtitle = 'Be the first to RSVP and start the party! 🎉';
        icon = Icons.thumb_up_rounded;
        accentColor = Colors.green;
        break;
      case RSVPStatus.MAYBE:
        title = 'No maybes yet';
        subtitle = 'Waiting to see who might join... 🤔';
        icon = Icons.question_mark_rounded;
        accentColor = Colors.orange;
        break;
      case RSVPStatus.NOT_GOING:
        title = 'All clear!';
        subtitle = 'Everyone who declined is listed here when they do.';
        icon = Icons.thumb_down_rounded;
        accentColor = Colors.red.shade300;
        break;
      case RSVPStatus.UNDECIDED:
        title = 'No pending invites';
        subtitle = 'All invites have been responded to! ✨';
        icon = Icons.mark_email_read_rounded;
        accentColor = Colors.blue.shade300;
        break;
      default:
        title = 'No attendees yet';
        subtitle = 'The guest list will appear here once people RSVP.';
        icon = Icons.people_outline_rounded;
        accentColor = primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: generalAppLevelPadding * 2,
        vertical: generalAppLevelPadding * 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated icon container with gradient-like effect
          Container(
            padding: const EdgeInsets.all(generalAppLevelPadding * 1.5),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  accentColor.withOpacity(0.15),
                  accentColor.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(generalAppLevelPadding),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 56,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: generalAppLevelPadding * 1.5),
          // Title
          ProText(
            title,
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: eventTheme?.colorScheme.primary ??
                  Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: generalAppLevelPadding / 2),
          // Subtitle
          ProText(
            subtitle,
            textStyle: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: eventTheme?.colorScheme.primary ??
                  Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          // Decorative dots or pattern for visual interest
          const SizedBox(height: generalAppLevelPadding * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
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
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: ProAddComment(
                            onUpdate: (final Comment comment) {
                              if (receivedEvent.comments == null) {
                                receivedEvent.comments = [];
                              }
                              addCommentToEvent(receivedEvent, comment, context)
                                  .then((comment) {
                                if (comment != null) {
                                  receivedEvent.comments!.add(comment);
                                }
                                ref
                                    .read(eventProvider.notifier)
                                    .updateEvent(receivedEvent);
                              });
                            },
                            user: cookiesService.locallyAvailableUserInfo),
                      ),
                      theme: eventTheme,
                      themeType: themeType,
                      gradientColors: _gradientColors,
                    );
                  },
                  child: ProText('Comment'),
                ),
              ],
            ),
            if (receivedEvent.comments != null &&
                receivedEvent.comments!.isNotEmpty)
              ..._buildComments(
                  receivedEvent, cookiesService.currentJwtToken == null),
            if (receivedEvent.comments == null ||
                receivedEvent.comments!.isEmpty)
              SizedBox(
                  height: 200,
                  child: Center(
                      child: const ProText(
                          textStyle: TextStyle(
                            fontSize: 16,
                          ),
                          'Be the first to break the silence! 🎤'))),
            // const SizedBox(height: 200),
          ])),
    );
  }

  List<Widget> _buildComments(Event event, final bool hideNames) {
    event.comments?.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return event.comments
            ?.map((comment) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: generalAppLevelPadding),
                  child: ProUserComment(
                      comment: comment,
                      onDelete: (comment) {
                        deleteCommentFromEvent(event, comment, context)
                            .then((value) {
                          setState(() {
                            event.comments?.remove(comment);
                          });
                        });
                      },
                      canDelete:
                          (cookiesService.locallyAvailableUserInfo != null &&
                                  comment.user.email ==
                                      cookiesService
                                          .locallyAvailableUserInfo!.email) ||
                              event.isHostedByMe(
                                  cookiesService.locallyAvailableUserInfo),
                      hideNames: event.isGuestListHidden || hideNames),
                ))
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
      // Only update if scroll offset is negative (overscroll)
      if (_scrollController.offset < 0) {
        _scrollOffsetNotifier.value = _scrollController.offset;
      } else {
        // Reset to 0 when scrolling normally
        if (_scrollOffsetNotifier.value != 0.0) {
          _scrollOffsetNotifier.value = 0.0;
        }
      }
    });
    _eventFuture = findEventWithId(widget.eventId!);
  }

  void _initializeGradient(Event? eventData) {
    if (eventData != null && eventData.imageUrl.isNotEmpty) {
      // Extract multiple colors for gradient
      extractSectionDominantColors(
        eventData.imageUrl,
        mounted,
      ).then((colors) {
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
    _scrollOffsetNotifier.dispose();
    if (kIsWeb) {
      // Clean up meta tags when leaving the page
      platform.removeMetaTags();
    }
    super.dispose();
  }

  void updateGradient() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeGradient(event);
      }
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    // Listen to event provider changes to refresh the event when updated
    // This is safe to call in build - Riverpod ensures it only sets up once
    ref.listen<EventProviderState>(eventProvider, (previous, next) {
      // Only rebuild if the event ID matches and it's an update
      if (next.crudOperation == CrudOperation.update ||
          next.crudOperation == CrudOperation.rsvp_update) {
        // Check if RSVP status changed to GOING and trigger celebration
        if (next.event != null) {
          final newRsvpStatus = next.event!
              .getRsvpStatusForUser(cookiesService.locallyAvailableUserInfo);
          // Trigger celebration if status changed to GOING
          if (newRsvpStatus == RSVPStatus.GOING &&
              next.crudOperation == CrudOperation.rsvp_update) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (mounted) {
                final celebrationOverlay = _celebrationKey.currentState;
                if (celebrationOverlay != null) {
                  celebrationOverlay.play();
                  // Delay rebuild until after celebration starts
                  if (mounted) {
                    setState(() {});
                  }
                } else {
                  // print("ERROR: celebrationOverlay is null!");
                  // If overlay not ready, rebuild anyway
                  if (mounted) {
                    setState(() {});
                  }
                }
              }
            });
          } else {
            // No celebration, rebuild immediately
            // print("redbuilding");
            if (mounted) {
              setState(() {
                event = next.event;
              });
            }
          }
        } else {
          // No previous event, rebuild immediately
          if (mounted) {
            setState(() {
              event = next.event;
            });
          }
        }
      }
    });

    return FutureBuilder(
        future: _eventFuture,
        builder: (context, AsyncSnapshot<Event?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              event == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final newEvent = snapshot.data!;
            // Initialize gradient when event is loaded or changed
            if (event == null ||
                event!.updatedAt.compareTo(newEvent.updatedAt) < 0) {
              event = newEvent;
              if (event != null) {
                updateGradient();
              }
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
