import '../utils/constants.dart';

class EventToAttendee {
  int? id;
  String eventId;
  String userId;
  String? rsvpStatus;

  EventToAttendee({
    this.id,
    required this.eventId,
    required this.userId,
    this.rsvpStatus
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'rsvpStatus': rsvpStatus
    };
  }

  factory EventToAttendee.fromMap(Map<String, dynamic> map) {
    try {
      return EventToAttendee(
        eventId: map['eventId'],
        userId: map['userId'].toString(),
        rsvpStatus: map['rsvpStatus'],
      );
    } catch (e) {
      print(e);
      return EventToAttendee(eventId: '', userId: '');
    }
  }

  static String getCreateTableSchema() {
    return '''
      CREATE TABLE IF NOT EXISTS $eventToAttendeeTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId TEXT,
        userId TEXT,
        rsvpStatus TEXT,
        UNIQUE(eventId, userId)
        )
    ''';
  }

  @override
  String toString() {
    return 'EventToAttendee(id: $id, eventId: $eventId, userId: $userId, rsvpStatus: $rsvpStatus)';
  }
}
