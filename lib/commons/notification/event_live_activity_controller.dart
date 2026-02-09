import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:live_activities/live_activities.dart';
import 'package:live_activities/models/live_activity_file.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/models/user.dart';

/// iOS Live Activity window: starts 20 min before event, ends at event end time
/// (or 1 hour after start if no end time).
class EventLiveActivityController {
  EventLiveActivityController({
    required this.appGroupId,
    this.urlScheme,
    bool Function(Event event, User? user)? eligibilityChecker,
  }) : _eligibilityChecker =
            eligibilityChecker ?? _defaultEligibilityChecker;

  final String appGroupId;
  final String? urlScheme;
  final bool Function(Event event, User? user) _eligibilityChecker;

  static bool _defaultEligibilityChecker(Event event, User? user) {
    if (user == null || event.id == null || event.startDateTime == null) {
      return false;
    }
    final status = event.getRsvpStatusForUser(user);
    return status == RSVPStatus.GOING || status == RSVPStatus.MAYBE;
  }

  final LiveActivities _plugin = LiveActivities();
  bool _initialized = false;

  static const Duration _windowStartOffset = Duration(minutes: 20);
  static const Duration _windowEndOffsetIfNoEnd = Duration(hours: 1);

  Future<void> init() async {
    if (kIsWeb || !Platform.isIOS) return;
    await _plugin.init(appGroupId: appGroupId, urlScheme: urlScheme);
    _initialized = true;
  }

  Future<bool> areActivitiesSupported() async {
    if (!_initialized) return false;
    return _plugin.areActivitiesSupported();
  }

  Future<bool> areActivitiesEnabled() async {
    if (!_initialized) return false;
    return _plugin.areActivitiesEnabled();
  }

  /// Window start = event start - 20 min.
  DateTime? getActivityWindowStart(Event event) {
    final start = event.startDateTime;
    if (start == null) return null;
    return start.subtract(_windowStartOffset);
  }

  /// Window end = event end time if set, else event start + 1 hour.
  DateTime? getActivityWindowEnd(Event event) {
    final start = event.startDateTime;
    if (start == null) return null;
    if (event.endDateTime != null) {
      return event.endDateTime;
    }
    return start.add(_windowEndOffsetIfNoEnd);
  }

  bool isInActivityWindow(Event event, DateTime now) {
    final windowStart = getActivityWindowStart(event);
    final windowEnd = getActivityWindowEnd(event);
    if (windowStart == null || windowEnd == null) return false;
    return !now.isBefore(windowStart) && now.isBefore(windowEnd);
  }

  /// Build the data map sent to the iOS Widget Extension (UserDefaults keys).
  Map<String, dynamic> buildActivityData(Event event) {
    final startTime = event.startDateTime != null
        ? DateFormat('h:mm a').format(event.startDateTime!.toLocal())
        : '';

    final map = <String, dynamic>{
      'eventId': event.id!,
      'startTime': startTime,
    };

    if (event.imageUrl.isNotEmpty) {
      map['eventImage'] = LiveActivityFileFromUrl.image(
        event.imageUrl,
        imageOptions: LiveActivityImageFileOptions(resizeFactor: 0.2),
      );
    }

    if (!event.isGuestCountHidden &&
        event.attendees != null &&
        event.attendees!.isNotEmpty) {
      final count = event.getAttendeesAndPlusOnesByRsvpStatus(RSVPStatus.GOING).length;
      map['guestCount'] = count;
    }

    final location = event.location?.trim();
    if (location != null && location.isNotEmpty) {
      map['location'] = location;
    }

    return map;
  }

  /// Start a Live Activity for this event. Call when app is in foreground and
  /// [isInActivityWindow(event, now)] is true.
  Future<void> startForEvent(Event event, User? user) async {
    if (kIsWeb || !Platform.isIOS || !_initialized) return;
    if (!_eligibilityChecker(event, user)) return;
    if (event.id == null || event.startDateTime == null) return;
    final supported = await areActivitiesSupported();
    final enabled = await areActivitiesEnabled();
    if (!supported || !enabled) return;

    final now = DateTime.now();
    if (!isInActivityWindow(event, now)) return;

    final activityId = event.id!;
    final data = buildActivityData(event);
    try {
      await _plugin.createActivity(
        activityId,
        data,
        removeWhenAppIsKilled: true,
        staleIn: getActivityWindowEnd(event)?.difference(now),
      );
    } catch (_) {
      // Ignore (e.g. duplicate, or OS limit)
    }
  }

  /// End the Live Activity for this event.
  Future<void> endForEvent(String eventId) async {
    if (kIsWeb || !Platform.isIOS || !_initialized) return;
    try {
      await _plugin.endActivity(eventId);
    } catch (_) {}
  }

  /// End all Live Activities.
  Future<void> endAll() async {
    if (kIsWeb || !Platform.isIOS || !_initialized) return;
    try {
      await _plugin.endAllActivities();
    } catch (_) {}
  }

  /// Sync Live Activities with the current list of events and current user:
  /// start activities for events in window, end activities for events past window
  /// or not in the list.
  Future<void> syncFromEvents(List<Event> events, User? user) async {
    if (kIsWeb || !Platform.isIOS || !_initialized) return;
    final supported = await areActivitiesSupported();
    final enabled = await areActivitiesEnabled();
    if (!supported || !enabled) return;

    final now = DateTime.now();
    final eligibleEventIds = <String>{};

    for (final event in events) {
      if (event.id == null) continue;
      if (!_eligibilityChecker(event, user)) continue;
      eligibleEventIds.add(event.id!);

      if (isInActivityWindow(event, now)) {
        await startForEvent(event, user);
      } else {
        final windowEnd = getActivityWindowEnd(event);
        if (windowEnd != null && now.isAfter(windowEnd)) {
          await endForEvent(event.id!);
        }
      }
    }

    final activityIds = await _plugin.getAllActivitiesIds();
    for (final id in activityIds) {
      if (!eligibleEventIds.contains(id)) {
        await endForEvent(id);
      }
    }
  }
}
