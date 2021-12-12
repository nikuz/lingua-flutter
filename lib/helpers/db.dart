import 'dart:async';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;
  static final DBHelper instance = DBHelper._privateConstructor();

  DBHelper._privateConstructor();

  factory DBHelper() {
    return instance;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  _initDatabase() async {
    return await openDatabase('dictionary.SQLITE3', version: 1, onCreate: this.createTable);
  }

  Future createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dictionary (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        word VARCHAR NOT NULL COLLATE NOCASE,
        pronunciation VARCHAR,
        translation VARCHAR COLLATE NOCASE,
        raw TEXT NOT NULL,
        image VARCHAR,
        version INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
      '''
    );
  }

  Future<List<Map>> rawQuery(String query, List<dynamic> arguments) async {
    Database db = await instance.database;
    return await db.rawQuery(query, arguments);
  }

  Future<int> rawInsert(String table, Map<String, dynamic> values) async {
    Database db = await instance.database;
    return await db.insert(table, values);
  }

  Future<int> rawUpdate(String query, List<dynamic> arguments) async {
    Database db = await instance.database;
    return await db.rawUpdate(query, arguments);
  }

  Future<int> rawDelete(String query, List<dynamic> arguments) async {
    Database db = await instance.database;
    return await db.rawDelete(query, arguments);
  }

  Future<List<dynamic>> batchQuery(List<Map<String, dynamic>> props, {bool? noResult}) async {
    Database db = await instance.database;
    Batch batch = db.batch();

    for (int i = 0, l = props.length; i < l; i++) {
      final Map<String, dynamic> item = props[i];
      String? type = item['type'];
      String? query = item['query'];
      List<dynamic>? arguments = item['arguments'];

      switch (type) {
        case 'rawQuery':
          batch.rawQuery(query!, arguments);
          break;
        case 'rawInsert':
          batch.rawInsert(query!, arguments);
          break;
        case 'rawUpdate':
          batch.rawUpdate(query!, arguments);
          break;
        case 'rawDelete':
          batch.rawDelete(query!, arguments);
          break;
        default:
      }
    }

    return await batch.commit(noResult: noResult ?? false);
  }

  void close() async {
    Database db = await instance.database;
    await db.close();
    _db = null;
  }
}

