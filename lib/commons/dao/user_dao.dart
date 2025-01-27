import '../utils/constants.dart';
import '../models/user.dart';
import 'package:sqflite/sqflite.dart';

class UserDAO {
  final Database _database;

  UserDAO(this._database) {
    initTable();
  }

  Future<void> initTable() async {
    String userTableSchema = User.getCreateTableSchema();
    await _database.execute(userTableSchema);
  }

  Future<bool> isTableEmpty() async {
    return Sqflite.firstIntValue(
            await _database.rawQuery('SELECT COUNT(*) FROM $userTableName')) ==
        0;
  }

  Future<List<User>> getAllUsers() async {
    final List<Map<String, dynamic>> maps =
        await _database.query(userTableName);
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<int> addUser(User user) async {
    return await _database.insert(
      userTableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserById(String userId) async {
    final List<Map<String, dynamic>> maps =
        await _database.query(userTableName, where: 'id = ?', whereArgs: [userId]);
    if (maps.isEmpty) {
      return null;
    }
    User? user = null;
    try {
      user = User.fromMap(maps.first);
    } catch (e) {
      print(e);
    }

    return user;
  }

  Future<void> updateUser(User user) async {
    await _database.update(
      userTableName,
      user.toMap(),
      where: 'email = ?',
      whereArgs: [user.email],
    );
  }

  Future<void> deleteAllUsers() async {
    await _database.delete(userTableName);
  }

  Future<User?> findUserById(String userId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      userTableName,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    try {
      return User.fromMap(maps.first);
    } catch (e) {
      print('Error parsing user: $e');
      return null;
    }
  }
}
