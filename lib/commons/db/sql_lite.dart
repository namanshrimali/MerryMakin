import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDBHelper {
  static Database? _database;

  SQLiteDBHelper._(); // Private constructor to prevent instantiation

  static final SQLiteDBHelper instance = SQLiteDBHelper._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Do nothing here. Tables will be initialized by respective DAO classes.
  }
}
