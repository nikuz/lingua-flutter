import 'package:sqflite/sqflite.dart';
import 'package:lingua_flutter/utils/files.dart';

Database db;

Future<void> dbOpen() async {
  String dir = await getDocumentsPath();
  db = await openDatabase('$dir/database/dictionary.SQLITE3');
}

void dbClose() async {
  await db.close();
  db = null;
}

Future<List<Map>> dbRawQuery(String query, List<dynamic> arguments) async => (
    await db.rawQuery(query, arguments)
);

Future<int> dbRawInsert(String table, Map<String, dynamic> values) async => (
    await db.insert(table, values)
);

Future<int> dbRawUpdate(String query, List<dynamic> arguments) async => (
    await db.rawUpdate(query, arguments)
);

Future<int> dbRawDelete(String query, List<dynamic> arguments) async => (
    await db.rawDelete(query, arguments)
);

Future<List<dynamic>> dbBatchQuery(List<Map<String, dynamic>> props, {bool noResult}) async {
  Batch batch = db.batch();

  for (int i = 0, l = props.length; i < l; i++) {
    final Map<String, dynamic> item = props[i];
    String type = item['type'];
    String query = item['query'];
    List<dynamic> arguments = item['arguments'];

    switch (type) {
      case 'rawQuery':
        batch.rawQuery(query, arguments);
        break;
      case 'rawInsert':
        batch.rawInsert(query, arguments);
        break;
      case 'rawUpdate':
        batch.rawUpdate(query, arguments);
        break;
      case 'rawDelete':
        batch.rawDelete(query, arguments);
        break;
      default:
    }
  }

  return await batch.commit(noResult: noResult ?? false);
}
