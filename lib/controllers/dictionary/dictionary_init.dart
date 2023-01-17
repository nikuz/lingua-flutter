import 'package:lingua_flutter/providers/db.dart';

Future<void> init() async {
  await DBProvider().batchQuery([
    const BatchQueryRequest(
      type: 'rawQuery',
      query: '''
        CREATE TABLE IF NOT EXISTS dictionary (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        word VARCHAR NOT NULL COLLATE NOCASE,
        pronunciationFrom VARCHAR,
        pronunciationTo VARCHAR,
        translation VARCHAR COLLATE NOCASE,
        raw TEXT NOT NULL,
        image VARCHAR,
        translate_from VARCHAR NOT NULL,
        translate_from_code VARCHAR NOT NULL,
        translate_to VARCHAR NOT NULL,
        translate_to_code VARCHAR NOT NULL,
        schema_version VARCHAR NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
      ''',
    ),
    const BatchQueryRequest(
      type: 'rawQuery',
      query: '''
        CREATE INDEX IF NOT EXISTS dictionary_index
        ON dictionary(word, translation)
      ''',
    )
  ]);
}