import '../utils/constants.dart';
import '../models/cookies.dart';
import 'package:sqflite/sqflite.dart';

class CookiesDAO {
  final Database _database;

  CookiesDAO(this._database) {
    initTable();
  }

  Future<void> initTable() async {
    String goalTableSchema = Cookie.getCreateTableSchema();
    await _database.execute(goalTableSchema);
  }

  Future<bool> isTableEmpty() async {
    return Sqflite.firstIntValue(await _database
            .rawQuery('SELECT COUNT(*) FROM $cookiesTableName')) ==
        0;
  }

  Future<void> insertCookie(Cookie cookie) async {
    await _database.insert(
      cookiesTableName,
      cookie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Cookie?> getCookie() async {
    final List<Map<String, dynamic>> maps =
        await _database.query(cookiesTableName);
    if (maps.isEmpty) {
      return null;
    }
    return Cookie.fromMap(maps.first);
  }

  Future<void> updateCookie(Cookie cookie) async {
    await _database.update(
      cookiesTableName,
      cookie.toMap(),
      where: 'id = ?',
      whereArgs: [cookie.id],
    );
  }

  Future<void> deleteCookie() async {
    await _database.delete(cookiesTableName);
  }

  Future<void> alterTableAddColumnOfTEXTTypeIfDoesntExist(
      String newColumnName, String defaultValue) async {
    final existingColumns =
        await _database.rawQuery('PRAGMA table_info($cookiesTableName)');
    List<String> existingColumnsList =
        existingColumns.map((row) {
          return row['name'] as String;
        }).toList();
    if (!existingColumnsList.contains(newColumnName)) {
      // Column doesn't exist, so add it with a default value
      _database.execute(
          'ALTER TABLE $cookiesTableName ADD COLUMN $newColumnName TEXT');
    }
  }

  Future<void> alterTableAddColumnOfINTEGERTypeIfDoesntExist(
      String newColumnName, String defaultValue) async {
    final existingColumns =
        await _database.rawQuery('PRAGMA table_info($cookiesTableName)');
    List<String> existingColumnsList =
        existingColumns.map((row) {
          return row['name'] as String;
        }).toList();
    if (!existingColumnsList.contains(newColumnName)) {
      // Column doesn't exist, so add it with a default value
      _database.execute(
          'ALTER TABLE $cookiesTableName ADD COLUMN $newColumnName INTEGER DEFAULT $defaultValue');
    }
  }
}
