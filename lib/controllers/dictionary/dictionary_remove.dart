import 'dart:io';
import 'package:lingua_flutter/models/error.dart';
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/files.dart';

import './constants.dart';

Future<void> removeItem(int id) async {
  final List<dynamic> dbResponse = await DBProvider().rawQuery(
    'SELECT * FROM ${DictionaryControllerConstants.databaseTableName} WHERE id=?;',
    [id],
  );

  if (dbResponse.isEmpty) {
    throw const CustomError(
      code: 404,
      message: 'Such translation does not exist in the local database',
    );
  }

  final item = dbResponse[0];
  final dir = await getDocumentsPath();
  final image = File('$dir${item['image']}');
  if (image.existsSync()) {
    image.deleteSync();
  }
  final pronunciationFrom = File('$dir${item['pronunciationFrom']}');
  if (pronunciationFrom.existsSync()) {
    pronunciationFrom.deleteSync();
  }
  final pronunciationTo = File('$dir${item['pronunciationTo']}');
  if (pronunciationTo.existsSync()) {
    pronunciationTo.deleteSync();
  }

  await DBProvider().rawDelete('DELETE FROM ${DictionaryControllerConstants.databaseTableName} WHERE id=?;', [id]);
}