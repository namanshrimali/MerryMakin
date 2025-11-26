import 'package:flutter/material.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/oauth_login.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';

import '../commons/models/event.dart';
import '../commons/models/event_attendee.dart';
import '../commons/models/rsvp.dart';
import '../commons/models/spryly_services.dart';
import '../commons/models/user.dart';
import '../commons/themes/pro_themes.dart';
import '../commons/widgets/buttons/pro_outlined_button.dart';
import '../commons/widgets/buttons/pro_primary_button.dart';
import '../commons/widgets/cards/pro_card.dart';
import '../commons/widgets/pro_list_view.dart';
import '../commons/widgets/pro_share_sheet.dart';
import '../commons/widgets/pro_snackbar.dart';
import '../commons/widgets/pro_tab_view.dart';
import '../commons/widgets/pro_text.dart';
import '../commons/widgets/pro_theme_effects.dart';
import '../commons/widgets/pro_user_avatar.dart';
import '../factory/app_factory.dart';

class GuestList extends StatelessWidget {
  final Event event;
  final double maxHeight;
  final ThemeData? eventTheme;
  final ProEffectType? effectType;
  final ProThemeType themeType;
  final List<Color> gradientColors;
  const GuestList(
      {super.key,
      required this.event,
      required this.maxHeight,
      this.eventTheme,
      required this.themeType,
      required this.gradientColors,
      this.effectType});

  Widget _buildGuestList(
    BuildContext buildContext,
    bool isUserAuthorized,
  ) {
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
                if (isUserAuthorized)
                  ProOutlinedButton(
                    onPressed: () {
                      openProBottomModalSheet(
                        gradientColors: [gradientColors[0]],
                        buildContext,
                        _buildAllAttendeesWithStatus(
                            maxHeight * 0.4, buildContext),
                        theme: eventTheme,
                        themeType: themeType,
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
              GestureDetector(
                onTap: () {
                  if (!isUserAuthorized) {
                    return;
                  }
                  openProBottomModalSheet(
                    gradientColors: [gradientColors[0]],
                    buildContext,
                    _buildAllAttendeesWithStatus(maxHeight * 0.4, buildContext),
                  );
                },
                child: _buildStackedAvatars(
                    goingAttendees + maybeAttendees,
                    false,
                    0,
                    eventTheme?.colorScheme.primary ??
                        Theme.of(buildContext).colorScheme.primary,
                    isUserAuthorized),
              ),
            ] else if (event.isGuestCountHidden && hasGuests) ...[
              // Show avatars but hide counts
              _buildHiddenCountGuestAvatars(goingAttendees, maybeAttendees),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUnAuthorizedGuestState(BuildContext buildContext) {
    return Padding(
      padding: const EdgeInsets.only(
        left: generalAppLevelPadding,
        right: generalAppLevelPadding,
      ),
      child: ProCard(
        elevation: 10,
        surfaceTintColor: Colors.white.withOpacity(0.1),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: generalAppLevelPadding * 2),
          child: Column(
            children: [
              // Fun icon with animation-ready container
              Container(
                padding: const EdgeInsets.all(generalAppLevelPadding),
                decoration: BoxDecoration(
                  color:
                      (ProThemes.themes[themeType]?.theme.colorScheme.primary ??
                              Theme.of(buildContext).colorScheme.primary)
                          .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 48,
                  color:
                      ProThemes.themes[themeType]?.theme.colorScheme.primary ??
                          Theme.of(buildContext).colorScheme.primary,
                ),
              ),
              const SizedBox(height: generalAppLevelPadding),
              ProText(
                'Get in the Know—Sign Up for the Guest List!',
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: generalAppLevelPadding / 2),
              ProText(
                "Privacy first, party second! See who's coming once you're in the mix.",
                textStyle: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: generalAppLevelPadding * 1.5),
              ProPrimaryButton(
                ProText("Sign Up"),
                onPressed: () {
                  openProBottomModalSheet(
                      buildContext,
                      OAuthLogin(
                          userService: AppFactory().userService,
                          sprylyService: SprylyServices.MerryMakin.name));
                },
              ),
            ],
          ),
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
                      Theme.of(buildContext).colorScheme.primary)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.celebration_rounded,
              size: 48,
              color: ProThemes.themes[themeType]?.theme.colorScheme.primary ??
                  Theme.of(buildContext).colorScheme.primary,
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
                  userService: AppFactory().userService,
                  onShare: (value) {
                    showSnackBar(buildContext, value);
                  },
                  event: event,
                  themeType: themeType,
                  effectType: effectType,
                ),
                theme: eventTheme,
                themeType: themeType,
                gradientColors: [gradientColors[0]],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStackedAvatars(List<Attendee> attendees, bool hasOverflow,
      int overflowCount, Color accentColor, bool isUserAuthorized) {
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
                    hideMode: !isUserAuthorized),
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

  Widget _buildAllAttendeesWithStatus(double? height, BuildContext context) {
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
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.GOING),
            RSVPStatus.GOING, context),
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.MAYBE),
            RSVPStatus.MAYBE, context),
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.NOT_GOING),
            RSVPStatus.NOT_GOING, context),
        _buildAttendeeList(event.getAttendeesByRsvpStatus(RSVPStatus.UNDECIDED),
            RSVPStatus.UNDECIDED, context),
        _buildAttendeeList(event.attendees!, null, context),
      ],
    );
  }

  Widget _buildAttendeeList(
      List<Attendee> attendees, RSVPStatus? status, BuildContext context) {
    if (attendees.isEmpty) {
      return _buildEmptyAttendeeState(status, context);
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

  Widget _buildEmptyAttendeeState(RSVPStatus? status, BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final User? user = AppFactory().cookiesService.currentUser;
    final isUserAuthorized = user?.isUserAuthorized() ?? false;
    // if (!isUserAuthorized) {
    //   return _buildUnAuthorizedGuestState(context);
    // }
    return _buildGuestList(context, isUserAuthorized);
  }
}
