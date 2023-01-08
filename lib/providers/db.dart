import 'dart:async';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static Database? _db;
  static final DBProvider instance = DBProvider._privateConstructor();

  DBProvider._privateConstructor();

  factory DBProvider() {
    return instance;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase('database/dictionary.SQLITE3', version: 1);
  }

  Future execute(String query) async {
    Database db = await instance.database;
    await db.execute(query);
  }

  Future<List<Map>> rawQuery(String query, [List<dynamic>? arguments]) async {
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

  Future<List<dynamic>> batchQuery(List<BatchQueryRequest> requests) async {
    Database db = await instance.database;
    Batch batch = db.batch();

    for (var request in requests) {
      switch (request.type) {
        case 'rawQuery':
          batch.rawQuery(request.query, request.arguments);
          break;
        case 'rawInsert':
          batch.rawInsert(request.query, request.arguments);
          break;
        case 'rawUpdate':
          batch.rawUpdate(request.query, request.arguments);
          break;
        case 'rawDelete':
          batch.rawDelete(request.query, request.arguments);
          break;
        default:
      }
    }

    return await batch.commit();
  }

  void close() async {
    Database db = await instance.database;
    await db.close();
    _db = null;
  }
}

class BatchQueryRequest {
  final String type;
  final String query;
  final List<Object>? arguments;

  const BatchQueryRequest({
    required this.type,
    required this.query,
    this.arguments,
  });
}

Future<String> getDbPath() async {
  String dbPath = await getDatabasesPath();
  if (!dbPath.endsWith('/')) {
    dbPath += '/';
  }
  return dbPath;
}