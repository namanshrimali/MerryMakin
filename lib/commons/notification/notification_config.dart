import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/models/user.dart';

/// Determines whether notifications should be scheduled for an event for the given user.
/// Inject a custom implementation to change eligibility rules.
abstract class NotificationEligibilityChecker {
  bool shouldScheduleForEvent(Event event, User? user);
}

/// Default: schedule for GOING, MAYBE, or host; only for future events.
class DefaultNotificationEligibilityChecker implements NotificationEligibilityChecker {
  @override
  bool shouldScheduleForEvent(Event event, User? user) {
    if (user == null || event.id == null || event.startDateTime == null) {
      return false;
    }
    final now = DateTime.now();
    if (!event.startDateTime!.isAfter(now)) {
      return false;
    }
    final rsvpStatus = event.getRsvpStatusForUser(user);
    if (rsvpStatus == RSVPStatus.GOING || rsvpStatus == RSVPStatus.MAYBE) {
      return true;
    }
    if (event.isHostedByMe(user)) {
      return true;
    }
    return false;
  }
}
