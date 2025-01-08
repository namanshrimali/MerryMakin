import 'package:merrymakin/commons/models/event_to_host.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class EventToHostDao {
  final Database _database;

  EventToHostDao(this._database) {
    initTable();
  }

  Future<void> initTable() async {
    String schema = EventToHost.getCreateTableSchema();
    await _database.execute(schema);
  }

  Future<List<EventToHost>> queryAll() async {
    List<Map<String, dynamic>> results =
        await _database.query(eventToHostTableName);
    return results.map((row) => EventToHost.fromMap(row)).toList();
  }

  Future<List<EventToHost>> getHostsForEvent(String eventId) async {
    final results = await _database.query(
      eventToHostTableName,
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
    return results.map((row) => EventToHost.fromMap(row)).toList();
  }

  Future<List<EventToHost>> getEventsForHost(String userId) async {
    final results = await _database.query(
      eventToHostTableName,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return results.map((row) => EventToHost.fromMap(row)).toList();
  }

  Future<int> insert(EventToHost eventToHost) async {
    return _database.insert(eventToHostTableName, eventToHost.toMap());
  }

  Future<void> delete(String eventId, String userId) async {
    await _database.delete(
      eventToHostTableName,
      where: 'eventId = ? AND userId = ?',
      whereArgs: [eventId, userId],
    );
  }

  Future<void> deleteAllForEvent(String eventId) async {
    await _database.delete(
      eventToHostTableName,
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> deleteAll() async {
    await _database.delete(
      eventToHostTableName,
    );
  }
}
