import 'package:flutter_test/flutter_test.dart';
import 'package:merrymakin/commons/notification/event_notification_scheduler.dart';
import 'package:merrymakin/commons/notification/notification_type.dart';

void main() {
  group('Notification type ID ranges', () {
    test('eventStart idBase is high enough to avoid overlap with twoHourReminder', () {
      // EventNotificationScheduler uses idBase + (hash % 999000), so twoHourReminder
      // range is [1000, 999999]. eventStart must use idBase >= 1000000 so ranges never overlap.
      expect(NotificationType.eventStart.idBase, greaterThanOrEqualTo(1000000));
      expect(NotificationType.twoHourReminder.idBase, lessThan(1000000));
    });
  });

  group('EventNotificationScheduler.getEventIdFromPayload', () {
    test('returns null for null payload', () {
      expect(EventNotificationScheduler.getEventIdFromPayload(null), isNull);
    });

    test('returns null for empty string payload', () {
      expect(EventNotificationScheduler.getEventIdFromPayload(''), isNull);
    });

    test('returns null for invalid JSON payload', () {
      expect(EventNotificationScheduler.getEventIdFromPayload('not json'), isNull);
      expect(EventNotificationScheduler.getEventIdFromPayload('{invalid'), isNull);
    });

    test('returns null when payload has no eventId key', () {
      expect(
        EventNotificationScheduler.getEventIdFromPayload('{"other":"value"}'),
        isNull,
      );
    });

    test('returns eventId when payload is valid JSON with eventId', () {
      expect(
        EventNotificationScheduler.getEventIdFromPayload('{"eventId":"ev-123"}'),
        equals('ev-123'),
      );
    });

    test('returns null when eventId value is null in JSON', () {
      expect(
        EventNotificationScheduler.getEventIdFromPayload('{"eventId":null}'),
        isNull,
      );
    });

    test('handles payload with extra keys', () {
      expect(
        EventNotificationScheduler.getEventIdFromPayload(
          '{"eventId":"ev-456","source":"notification"}',
        ),
        equals('ev-456'),
      );
    });

    test('handles numeric eventId by returning null (type mismatch)', () {
      // Decoding returns int; cast to String? fails, so we get null or cast error.
      // In practice payload is always jsonEncode({eventId: event.id}) so string.
      final result = EventNotificationScheduler.getEventIdFromPayload('{"eventId":123}');
      expect(result, isNull);
    });
  });
}
