import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/notification/notification_config.dart';
import 'package:merrymakin/commons/notification/notification_scheduler.dart';
import 'package:merrymakin/commons/notification/notification_type.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Event-specific implementation of [NotificationScheduler] using
/// flutter_local_notifications and timezone for scheduled reminders.
class EventNotificationScheduler implements NotificationScheduler {
  EventNotificationScheduler({
    NotificationEligibilityChecker? eligibilityChecker,
    void Function(String? eventId)? onNotificationTap,
  }) : _eligibilityChecker =
            eligibilityChecker ?? DefaultNotificationEligibilityChecker(),
       _onNotificationTap = onNotificationTap;

  final NotificationEligibilityChecker _eligibilityChecker;
  void Function(String? eventId)? _onNotificationTap;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _payloadKeyEventId = 'eventId';

  /// Set before [initialize] to handle notification taps (e.g. navigate to event).
  set onNotificationTap(void Function(String? eventId)? callback) {
    _onNotificationTap = callback;
  }

  @override
  Future<void> initialize() async {
    if (kIsWeb) return;
    await _initTimezone();
    await _initPlugin();
    await _createChannels();
    _initialized = true;
  }

  Future<void> _initTimezone() async {
    tz_data.initializeTimeZones();
  }

  Future<void> _initPlugin() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    const settings = InitializationSettings(android: android, iOS: darwin);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final eventId = getEventIdFromPayload(response.payload);
        _onNotificationTap?.call(eventId);
      },
    );
  }

  Future<void> _createChannels() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    for (final type in NotificationType.values) {
      final channel = AndroidNotificationChannel(
        type.channelId,
        _channelName(type.channelId),
        description: _channelDescription(type.channelId),
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  String _channelName(String channelId) {
    switch (channelId) {
      case 'event_reminders':
        return 'Event Reminders';
      case 'event_start':
        return 'Event Start';
      default:
        return 'Events';
    }
  }

  String _channelDescription(String channelId) {
    switch (channelId) {
      case 'event_reminders':
        return 'Reminders before your events start';
      case 'event_start':
        return 'Notifications when events are starting';
      default:
        return 'Event notifications';
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final result = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result == true;
    }
    return true;
  }

  @override
  Future<void> scheduleForEvent(Event event, User? user) async {
    if (kIsWeb || !_initialized) return;
    if (!_eligibilityChecker.shouldScheduleForEvent(event, user)) return;
    if (event.id == null || event.startDateTime == null) return;

    final now = DateTime.now();
    final eventStart = event.startDateTime!;

    for (final type in NotificationType.values) {
      final scheduledAt = eventStart.subtract(type.offset);
      if (!scheduledAt.isAfter(now)) continue;

      final id = _notificationId(event.id!, type);
      final details = _notificationDetails(type);
      final copy = type.copy(event);
      final payload = jsonEncode({_payloadKeyEventId: event.id});

      final tzScheduled = tz.TZDateTime.from(scheduledAt, tz.local);

      try {
        await _plugin.zonedSchedule(
          id,
          copy.title,
          copy.body,
          tzScheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
      } catch (_) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          try {
            await _plugin.zonedSchedule(
              id,
              copy.title,
              copy.body,
              tzScheduled,
              details,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: payload,
            );
          } catch (_) {
            // Permission denied or platform error; ignore
          }
        }
      }
    }
  }

  @override
  Future<void> cancelForEvent(String eventId) async {
    if (kIsWeb || !_initialized) return;
    for (final type in NotificationType.values) {
      final id = _notificationId(eventId, type);
      try {
        await _plugin.cancel(id);
      } catch (_) {}
    }
  }

  @override
  Future<void> syncAll(List<Event> events, User? user) async {
    if (kIsWeb || !_initialized) return;

    final seenIds = <String>{};
    for (final event in events) {
      if (event.id == null) continue;
      seenIds.add(event.id!);
      if (_eligibilityChecker.shouldScheduleForEvent(event, user)) {
        await cancelForEvent(event.id!);
        await scheduleForEvent(event, user);
      } else {
        await cancelForEvent(event.id!);
      }
    }

    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      final payload = p.payload;
      if (payload == null || payload.isEmpty) continue;
      try {
        final map = jsonDecode(payload) as Map<String, dynamic>;
        final eventId = map[_payloadKeyEventId] as String?;
        if (eventId != null && !seenIds.contains(eventId)) {
          await cancelForEvent(eventId);
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancelAll();
  }

  /// Notification IDs must be unique and non-overlapping across (eventId, type)
  /// to avoid cancelling the wrong notification. Each type uses a separate range.
  static const int _idRangePerType = 999000;

  int _notificationId(String eventId, NotificationType type) {
    final hash = Object.hash(eventId, type.name) & 0x7FFFFFFF;
    return type.idBase + (hash % _idRangePerType);
  }

  NotificationDetails _notificationDetails(NotificationType type) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        type.channelId,
        _channelName(type.channelId),
        channelDescription: _channelDescription(type.channelId),
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  /// Parses payload from a notification response and returns eventId if present.
  static String? getEventIdFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      return map[_payloadKeyEventId] as String?;
    } catch (_) {
      return null;
    }
  }
}
