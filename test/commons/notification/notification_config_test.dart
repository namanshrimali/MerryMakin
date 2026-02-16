import 'package:flutter_test/flutter_test.dart';
import 'package:merrymakin/commons/models/country_currency.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/event_attendee.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/notification/notification_config.dart';

void main() {
  late User hostUser;
  late User goingUser;
  late User maybeUser;
  late User notGoingUser;
  late User undecidedUser;

  setUp(() {
    hostUser = User(
      id: 'user-host',
      email: 'host@test.com',
      firstRegistered: DateTime(2020, 1, 1),
      timeStampWhenAuthorized: DateTime(2024, 1, 1),
    );
    goingUser = User(
      id: 'user-going',
      email: 'going@test.com',
      firstRegistered: DateTime(2020, 1, 1),
      timeStampWhenAuthorized: DateTime(2024, 1, 1),
    );
    maybeUser = User(
      id: 'user-maybe',
      email: 'maybe@test.com',
      firstRegistered: DateTime(2020, 1, 1),
      timeStampWhenAuthorized: DateTime(2024, 1, 1),
    );
    notGoingUser = User(
      id: 'user-notgoing',
      email: 'not@test.com',
      firstRegistered: DateTime(2020, 1, 1),
      timeStampWhenAuthorized: DateTime(2024, 1, 1),
    );
    undecidedUser = User(
      id: 'user-undecided',
      email: 'undecided@test.com',
      firstRegistered: DateTime(2020, 1, 1),
      timeStampWhenAuthorized: DateTime(2024, 1, 1),
    );
  });

  Event createEvent({
    required String? id,
    required DateTime? startDateTime,
    required List<User> hosts,
    List<Attendee>? attendees,
  }) {
    return Event(
      id: id,
      name: 'Test Event',
      imageUrl: '',
      startDateTime: startDateTime,
      hosts: hosts,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      countryCurrency: CountryCurrency.UnitedStatesDollarUnitedStates,
      attendees: attendees,
    );
  }

  group('DefaultNotificationEligibilityChecker', () {
    late DefaultNotificationEligibilityChecker checker;

    setUp(() {
      checker = DefaultNotificationEligibilityChecker();
    });

    test('returns false when user is null', () {
      final event = createEvent(
        id: 'e1',
        startDateTime: DateTime.now().add(const Duration(hours: 5)),
        hosts: [hostUser],
        attendees: [
          Attendee(user: goingUser, rsvpStatus: RSVPStatus.GOING, rsvpDate: DateTime.now()),
        ],
      );
      expect(checker.shouldScheduleForEvent(event, null), isFalse);
    });

    test('returns false when event id is null', () {
      final event = createEvent(
        id: null,
        startDateTime: DateTime.now().add(const Duration(hours: 5)),
        hosts: [hostUser],
        attendees: [
          Attendee(user: goingUser, rsvpStatus: RSVPStatus.GOING, rsvpDate: DateTime.now()),
        ],
      );
      expect(checker.shouldScheduleForEvent(event, goingUser), isFalse);
    });

    test('returns false when startDateTime is null', () {
      final event = createEvent(
        id: 'e1',
        startDateTime: null,
        hosts: [hostUser],
        attendees: [
          Attendee(user: goingUser, rsvpStatus: RSVPStatus.GOING, rsvpDate: DateTime.now()),
        ],
      );
      expect(checker.shouldScheduleForEvent(event, goingUser), isFalse);
    });

    test('returns false for past events', () {
      final event = createEvent(
        id: 'e1',
        startDateTime: DateTime.now().subtract(const Duration(hours: 1)),
        hosts: [hostUser],
        attendees: [
          Attendee(user: goingUser, rsvpStatus: RSVPStatus.GOING, rsvpDate: DateTime.now()),
        ],
      );
      expect(checker.shouldScheduleForEvent(event, goingUser), isFalse);
    });

    test('returns false when event start is exactly now (not after)', () {
      final now = DateTime.now();
      final event = createEvent(
        id: 'e1',
        startDateTime: now,
        hosts: [hostUser],
        attendees: [
          Attendee(user: goingUser, rsvpStatus: RSVPStatus.GOING, rsvpDate: DateTime.now()),
        ],
      );
      expect(checker.shouldScheduleForEvent(event, goingUser), isFalse);
    });

    test('returns true for future event when user is GOING', () {
      final event = createEvent(
        id: 'e1',
        startDateTime: DateTime.now().add(const Duration(hours: 5)),
        hosts: [hostUser],
        attendees: [
          Attendee(user: goingUser, rsvpStatus: RSVPStatus.GOING, rsvpDate: DateTime.now()),
        ],
      );
      expect(checker.shouldScheduleForEvent(event, goingUser), isTrue);
    });

    test('returns true for future event when user is MAYBE', () {
      final event = createEvent(
        id: 'e1',
        startDateTime: DateTime.now().add(const Duration(hours: 5)),
        hosts: [hostUser],
        attendees: [
          Attendee(user: maybeUser, rsvpStatus: RSVPStatus.MAYBE, rsvpDate: DateTime.now()),
        ],
      );
      expect(checker.shouldScheduleForEvent(event, maybeUser), isTrue);
    });

    test('returns true for future event when user is host (even without RSVP)', () {
      final event = createEvent(
        id: 'e1',
        startDateTime: DateTime.now().add(const Duration(hours: 5)),
        hosts: [hostUser],
        attendees: const [],
      );
      expect(checker.shouldScheduleForEvent(event, hostUser), isTrue);
    });

    test('returns false for future event when user is NOT_GOING', () {
      final event = createEvent(
        id: 'e1',
        startDateTime: DateTime.now().add(const Duration(hours: 5)),
        hosts: [hostUser],
        attendees: [
          Attendee(user: notGoingUser, rsvpStatus: RSVPStatus.NOT_GOING, rsvpDate: DateTime.now()),
        ],
      );
      expect(checker.shouldScheduleForEvent(event, notGoingUser), isFalse);
    });

    test('returns false for future event when user is UNDECIDED (no RSVP)', () {
      final event = createEvent(
        id: 'e1',
        startDateTime: DateTime.now().add(const Duration(hours: 5)),
        hosts: [hostUser],
        attendees: [
          Attendee(user: goingUser, rsvpStatus: RSVPStatus.GOING, rsvpDate: DateTime.now()),
        ],
      );
      expect(checker.shouldScheduleForEvent(event, undecidedUser), isFalse);
    });

    test('returns false when attendees is null (user not in list)', () {
      final event = createEvent(
        id: 'e1',
        startDateTime: DateTime.now().add(const Duration(hours: 5)),
        hosts: [hostUser],
        attendees: null,
      );
      expect(checker.shouldScheduleForEvent(event, goingUser), isFalse);
    });

    test('returns false when attendees is empty and user is not host', () {
      final event = createEvent(
        id: 'e1',
        startDateTime: DateTime.now().add(const Duration(hours: 5)),
        hosts: [hostUser],
        attendees: const [],
      );
      expect(checker.shouldScheduleForEvent(event, goingUser), isFalse);
    });
  });
}
