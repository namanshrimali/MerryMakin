import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/user.dart';

/// Contract for scheduling and cancelling event notifications.
/// Implementations can be swapped (e.g. NoOp for web/tests, EventNotificationScheduler for mobile).
abstract class NotificationScheduler {
  /// Schedule all eligible notification types for one event.
  Future<void> scheduleForEvent(Event event, User? user);

  /// Cancel all notifications for one event.
  Future<void> cancelForEvent(String eventId);

  /// Reconcile: schedule for eligible events, cancel for ineligible.
  Future<void> syncAll(List<Event> events, User? user);

  /// Clear all app-scheduled notifications (e.g. on logout).
  Future<void> cancelAll();

  /// Initialize plugin and timezone; call once at app startup.
  Future<void> initialize();

  /// Request notification permission (iOS / Android 13+).
  Future<bool> requestPermissions();
}

/// No-op implementation for web and tests. All methods return without doing anything.
class NoOpNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> scheduleForEvent(Event event, User? user) async {}

  @override
  Future<void> cancelForEvent(String eventId) async {}

  @override
  Future<void> syncAll(List<Event> events, User? user) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => false;
}
