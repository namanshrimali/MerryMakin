// import 'package:merrymakin/commons/models/event_to_attendee.dart';
// import 'package:merrymakin/commons/utils/constants.dart';
// import 'package:sqflite/sqflite.dart';

// class EventToAttendeeDao {
//   final Database _database;

//   EventToAttendeeDao(this._database) {
//     initTable();
//   }

//   Future<void> initTable() async {
//     String schema = EventToAttendee.getCreateTableSchema();
//     await _database.execute(schema);
//   }

//   Future<List<EventToAttendee>> queryAll() async {
//     List<Map<String, dynamic>> results =
//         await _database.query(eventToAttendeeTableName);
//     return results.map((row) => EventToAttendee.fromMap(row)).toList();
//   }

//   Future<EventToAttendee?> queryForEventAndUser(
//       final String eventId, final String userId) async {
//     List<Map<String, dynamic>> results = await _database.query(
//       eventToAttendeeTableName,
//       where: 'eventId = ? AND userId = ?',
//       whereArgs: [eventId, userId],
//     );
//     return results.map((row) => EventToAttendee.fromMap(row)).firstOrNull;
//   }

//   Future<List<EventToAttendee>> getEventToAttendeesForEvent(String eventId) async {
//     final results = await _database.query(
//       eventToAttendeeTableName,
//       where: 'eventId = ?',
//       whereArgs: [eventId],
//     );
//     return results.map((row) => EventToAttendee.fromMap(row)).toList();
//   }

//   Future<List<EventToAttendee>> getEventsForAttendee(String userId) async {
//     final results = await _database.query(
//       eventToAttendeeTableName,
//       where: 'userId = ?',
//       whereArgs: [userId],
//     );
//     return results.map((row) => EventToAttendee.fromMap(row)).toList();
//   }

//   Future<int> insert(EventToAttendee eventToAttendee) async {
//     return _database.insert(eventToAttendeeTableName, eventToAttendee.toMap());
//   }

//   Future<int> update(final EventToAttendee eventToAttendee) async {
//     return await _database.update(
//       eventToAttendeeTableName,
//       {'rsvpStatus': eventToAttendee.rsvpStatus},
//       where: 'eventId = ? AND userId = ?',
//       whereArgs: [eventToAttendee.eventId, eventToAttendee.userId],
//     );
//   }

//   Future<void> delete(String eventId, String userId) async {
//     await _database.delete(
//       eventToAttendeeTableName,
//       where: 'eventId = ? AND userId = ?',
//       whereArgs: [eventId, userId],
//     );
//   }

//   Future<void> deleteAllForEvent(String eventId) async {
//     await _database.delete(
//       eventToAttendeeTableName,
//       where: 'eventId = ?',
//       whereArgs: [eventId],
//     );
//   }

//   Future<void> deleteAll() async {
//     await _database.delete(
//       eventToAttendeeTableName,
//     );
//   }
// }
