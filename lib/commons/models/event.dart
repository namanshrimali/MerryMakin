import 'package:intl/intl.dart';
import 'package:merrymakin/commons/models/comment.dart';
import '../models/event_attendee.dart';
import '../models/event_request_dto.dart';
import '../models/rsvp.dart';
import '../service/cookies_service.dart';

// import '../models/event_to_attendee.dart';
import '../utils/constants.dart';

import './country_currency.dart';
import './user.dart';

class Event {
  String? id;
  String name;
  String imageUrl;
  DateTime? startDateTime;
  DateTime? endDateTime;
  String? description;
  String? location;
  int? spots; // number of spots available
  double? costPerSpot;
  CountryCurrency? countryCurrency;
  List<User> hosts;
  // List<EventToAttendee>? eventToAttendees;
  List<Attendee>? attendees;
  DateTime createdAt;
  DateTime updatedAt;
  List<Comment>? comments;
  String? dressCode;
  String? foodSituation;
  bool isGuestListHidden;
  bool isGuestCountHidden;
  List<Event>? subEvents;
  String? theme;
  String? effect;
  String? font;
  
  Event({
    this.id,
    required this.name,
    this.description,
    this.startDateTime,
    required this.hosts,
    // this.eventToAttendees,
    this.attendees,
    this.endDateTime,
    this.spots,
    this.costPerSpot,
    this.countryCurrency,
    this.imageUrl = '',
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.comments = const [],
    this.dressCode,
    this.foodSituation,
    this.isGuestListHidden = false,
    this.isGuestCountHidden = false,
    this.subEvents = const [],
    this.theme,
    this.effect,
    this.font,
  });

  @override
  String toString() {
    return '''Event{
      id: $id,
      name: $name,
      imageUrl: $imageUrl,
      startDateTime: $startDateTime,
      endDateTime: $endDateTime,
      description: $description,
      location: $location,
      spots: $spots,
      costPerSpot: $costPerSpot,
      countryCurrency: $countryCurrency,
      hosts: ${hosts.map((h) => h.toString()).toList()},
      attendees: ${attendees?.map((a) => a.toString()).toList()},
      createdAt: $createdAt,
      updatedAt: $updatedAt,
      comments: ${comments?.map((c) => c.toString()).toList()},
      dressCode: $dressCode,
      foodSituation: $foodSituation,
      isGuestListHidden: $isGuestListHidden,
      shouldShowGuestCount: $isGuestCountHidden,
      subEvents: ${subEvents?.map((e) => e.toString()).toList()},
      theme: $theme,
      effect: $effect,
      font: $font,
    }''';
    //       eventToAttendees: ${eventToAttendees?.map((a) => a.toString()).toList()},

  }

  factory Event.fromMap(Map<String, dynamic> map) {
    final Event event = Event(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      location: map['location'],
      spots: map['spots'],
      costPerSpot: map['costPerSpot'],
      startDateTime: map['startDateTime'] == null ||
              map['startDateTime'].toString().isEmpty
          ? null
          : DateTime.parse(map['startDateTime']),
      endDateTime:
          map['endDateTime'] == null || map['endDateTime'].toString().isEmpty
              ? null
              : DateTime.parse(map['endDateTime']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      countryCurrency: CountryCurrency.values
          .firstWhere((element) => element.name == map['countryCurrency']),
      hosts: List<User>.from(map['hosts'] == null
          ? []
          : map['hosts'].map((host) => User.fromMap(host)).toList()),
      attendees: List<Attendee>.from(map['attendees'] == null
          ? []
          : map['attendees']
              .map((attendee) => Attendee.fromMap(attendee))
              .toList()),
      comments: List<Comment>.from(map['comments'] == null
          ? []
          : map['comments']
              .map((comment) => Comment.fromMap(comment))
              .toList()),
      dressCode: map['dressCode'],
      foodSituation: map['foodSituation'],
      isGuestListHidden: map['isGuestListHidden'] != null && map['isGuestListHidden'],
      isGuestCountHidden: map['isGuestCountHidden'] != null && map['isGuestCountHidden'],
      subEvents: List<Event>.from(map['subEvents'] == null
          ? []
          : map['subEvents']
              .map((subEvent) => Event.fromMap(subEvent))
              .toList()),
      theme: map['theme'],
      effect: map['effect'],
      font: map['font'],
      // eventToAttendees: List<EventToAttendee>.from(map['eventToAttendees'] ==
      //         null
      //     ? []
      //     : map['eventToAttendees']
      //         .map(
      //             (eventToAttendee) => EventToAttendee.fromMap(eventToAttendee))
      //         .toList()),
    );
    return event;
  }

  static String getCreateTableSchema() {
    return '''
      CREATE TABLE IF NOT EXISTS $eventTableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        imageUrl TEXT,
        startDateTime TEXT NULL,
        endDateTime TEXT NULL,
        description TEXT NULL,
        location TEXT NULL,
        spots INTEGER NULL,
        costPerSpot REAL NULL,
        countryCurrency TEXT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        dressCode TEXT NULL,
        foodSituation TEXT NULL,
        isGuestListHidden INTEGER DEFAULT 0,
        isGuestCountHidden INTEGER DEFAULT 1,
        theme TEXT NULL,
        effect TEXT NULL,
        font TEXT NULL
        )
    ''';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description ?? '',
      'location': location ?? '',
      'spots': spots ?? 0,
      'costPerSpot': costPerSpot ?? 0.0,
      'startDateTime': startDateTime?.toIso8601String() ?? '',
      'endDateTime': endDateTime?.toIso8601String() ?? '',
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'countryCurrency': countryCurrency?.name,
      'comments': comments?.map((c) => c.toMap()).toList(),
      'dressCode': dressCode ?? '',
      'foodSituation': foodSituation ?? '',
      'isGuestListHidden': isGuestListHidden ? 1 : 0,
      'isGuestCountHidden': isGuestCountHidden ? 1 : 0,
      'subEvents': subEvents?.map((e) => e.toMap()).toList(),
      'theme': theme,
      'effect': effect,
      'font': font,
    };
  }

  bool isHostedByMe(final User? user) {
    if (user == null || user.id == null) {
      return false;
    }
    return hosts
        .where((host) => host.id != null && host.id! == user.id!)
        .isNotEmpty;
  }

  // bool isUserAttendee(final User user) {
  //   if (eventToAttendees == null || user.id == null) {
  //     return false;
  //   }
  //   return eventToAttendees!
  //       .where((EventToAttendee eventToAttendee) =>
  //           eventToAttendee.userId == user.id)
  //       .isNotEmpty;
  // }

  EventRequestDTO toEventRequestDTO() {
    return EventRequestDTO(
      id: id,
      name: name,
      imageUrl: imageUrl,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      description: description,
      location: location,
      spots: spots,
      costPerSpot: costPerSpot,
      countryCurrency: CookiesService.locallyStoredCountryCurrency.name,
      hostEmails: hosts.map((host) => host.email).toList(),
      attendeeEmails: attendees?.map((attendee) => attendee.user.email).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      comments: comments,
      dressCode: dressCode,
      foodSituation: foodSituation,
      subEvents: subEvents?.map((e) => e.toEventRequestDTO()).toList() ?? [],
    );
  }

  String get formattedStartDateTime {
    return startDateTime != null
        ? _formatDateTime(startDateTime!.toLocal())
        : 'To Be Decided';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now().toUtc();
    final difference = dateTime.difference(now).inDays;

    // Get 3-letter day name
    final dayName = DateFormat('EEE').format(dateTime);

    // Format time in 12-hour format with am/pm
    final hour = dateTime.hour == 12 || dateTime.hour == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'pm' : 'am';

    // If within 6 days, show only day name
    if (difference >= 0 && difference <= 6) {
      return '$dayName · $hour:$minute$period';
    }

    // Otherwise show full date
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$dayName $month/$day · $hour:$minute$period';
  }

  RSVPStatus getRsvpStatusForUser(final User? user) {
    if (attendees == null || attendees!.isEmpty || user == null || user.id == null) {
      return RSVPStatus.UNDECIDED;
    }

    return attendees!.where((attendee) => attendee.user.id == user.id).firstOrNull?.rsvpStatus ?? RSVPStatus.UNDECIDED;
  }

  List<Attendee> getAttendeesByRsvpStatus(RSVPStatus rsvpStatus) {
    return attendees!.where((attendee) => attendee.rsvpStatus == rsvpStatus).toList();
  }
}
