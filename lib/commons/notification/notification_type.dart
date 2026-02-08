import 'dart:math';

import 'package:intl/intl.dart';
import 'package:merrymakin/commons/models/event.dart';

/// Extensible notification types for event reminders.
/// Add new enum values (e.g. ONE_DAY_REMINDER) with config to extend.
enum NotificationType {
  /// Fires at startDateTime - 2 hours.
  twoHourReminder(
    offset: Duration(hours: 2),
    channelId: 'event_reminders',
    idBase: 1000,
  ),
  /// Fires at startDateTime.
  eventStart(
    offset: Duration.zero,
    channelId: 'event_start',
    idBase: 2000,
  );

  const NotificationType({
    required this.offset,
    required this.channelId,
    required this.idBase,
  });

  /// Time offset from event start (positive = before start).
  final Duration offset;

  /// Android channel ID / iOS category identifier.
  final String channelId;

  /// Base for notification ID generation (per type).
  final int idBase;

  static final _random = Random();

  /// Picks a random (title, body) pair for the event. Use this when scheduling
  /// so each scheduled notification gets a varied copy.
  ({String title, String body}) copy(Event event) {
    final options = _copyOptions;
    final i = _random.nextInt(options.length);
    final opt = options[i];
    return (title: opt.title, body: opt.body(event));
  }

  /// Title for the notification. Prefer [copy] to get randomized pairs.
  String title(Event event) => copy(event).title;

  /// Body for the notification. Prefer [copy] to get randomized pairs.
  String body(Event event) => copy(event).body;

  List<_CopyOption> get _copyOptions {
    switch (this) {
      case NotificationType.twoHourReminder:
        return [
          _CopyOption('Heads up — party in 2 hours', _twoHourBodyA),
          _CopyOption('2 hours to go', _twoHourBodyB),
          _CopyOption('Starting in 2 hours', _twoHourBodyC),
        ];
      case NotificationType.eventStart:
        return [
          _CopyOption("It's go time", _eventStartBodyA),
          _CopyOption("The party's on", _eventStartBodyB),
          _CopyOption('Happening now', _eventStartBodyC),
        ];
    }
  }
}

class _CopyOption {
  const _CopyOption(this.title, this.body);
  final String title;
  final String Function(Event) body;
}

String? _formatTime(DateTime? dt) =>
    dt != null ? DateFormat('h:mm a').format(dt.toLocal()) : null;

String _twoHourBodyA(Event e) {
  final time = _formatTime(e.startDateTime);
  final loc = e.location?.trim();
  if (time != null && loc != null && loc.isNotEmpty) {
    return '${e.name} • $time at $loc';
  }
  if (time != null) {
    return '${e.name} • $time';
  }
  return e.name;
}

String _twoHourBodyB(Event e) => '${e.name} — time to head over';

String _twoHourBodyC(Event e) => e.name;

String _eventStartBodyA(Event e) => '${e.name} — see you there';

String _eventStartBodyB(Event e) => '${e.name} has started';

String _eventStartBodyC(Event e) => e.name;
