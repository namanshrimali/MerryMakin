import '../utils/constants.dart';

class EventToHost {
  int? id;
  String eventId;
  String userId;

  EventToHost({
    this.id,
    required this.eventId,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
    };
  }

  factory EventToHost.fromMap(Map<String, dynamic> map) {
    EventToHost eventToHost = EventToHost(
      id: map['id'],
      eventId: map['eventId'],
      userId: map['userId'],
    );
    return eventToHost;
  }

  static String getCreateTableSchema() {
    return '''
      CREATE TABLE IF NOT EXISTS $eventToHostTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId TEXT,
        userId TEXT,
        UNIQUE(eventId, userId)
        )
    ''';
  }
}
