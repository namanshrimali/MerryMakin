import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class EventsDao {
  final Database _database;
  EventsDao(this._database) {
    initTable();
  }

  Future<void> initTable() async {
    String eventsTableSchema = Event.getCreateTableSchema();
    await _database.execute(eventsTableSchema);
  }

  Future<List<Event>> queryAll() async {
    List<Map<String, dynamic>> results = await _database.query(eventTableName);
    return results.map((row) => Event.fromMap(row)).toList();
  }

  Future<Event?> getEventWithId(String eventId) async {
    final eventResult = await _database.query(eventTableName,
        where: 'id = ?', whereArgs: [eventId.toString()]);
    if (eventResult.isEmpty) {
      return null; // Goal not found
    }

    return Event.fromMap(eventResult.first);
  }

  Future<int> insert(Event event) async {
    return _database.insert(eventTableName, event.toMap());
  }

  Future<void> update(Event event) async {
    await _database.update(
      eventTableName,
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> delete(String id) async {
    await _database.delete(eventTableName, where: 'id = ?', whereArgs: [id]);
  }

    Future<void> deleteAll() async {
    await _database.delete(eventTableName,);
  }
}
