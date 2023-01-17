import 'dart:io';
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/files.dart';

import './dictionary_init.dart';
import './constants.dart';

Future<void> clearDatabase() async {
  await DBProvider().rawQuery('DROP TABLE IF EXISTS ${DictionaryControllerConstants.databaseTableName}');

  String dir = await getDocumentsPath();
  final images = Directory('$dir/images');
  if (images.existsSync()) {
    images.deleteSync(recursive: true);
  }
  final pronunciations = Directory('$dir/pronunciations');
  if (pronunciations.existsSync()) {
    pronunciations.deleteSync(recursive: true);
  }

  await init();
}