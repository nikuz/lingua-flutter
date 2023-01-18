import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lingua_flutter/controllers/error_logger/error_logger.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/json.dart';
import 'package:lingua_flutter/models/error/error.dart';

final Map<String, String> languages = {};

Future<void> preload() async {
  final languagesPath = await _getLanguagesPath();
  final languagesDir = Directory(languagesPath);

  if (!(await languagesDir.exists())) {
    await languagesDir.create();
  }

  await for (var item in languagesDir.list()) {
    // read languages file
    final file = File(item.path);
    final languagesFileContent = await file.readAsString();

    // decode file JSON content
    Map<String, dynamic>? languagesData;
    try {
      Map<String, dynamic> languagesRawData = await jsonDecodeIsolate(languagesFileContent);
      languagesData = await jsonDecodeIsolate(languagesRawData['raw']);
    } catch (err, stack) {
      recordError(err, stack);
    }

    if (languagesData != null) {
      languages.clear();
      for (var id in languagesData.keys) {
        languages[id] = languagesData[id];
      }
    }
  }
}

Future<Map<String, String>?> get({ bool? forceUpdate }) async {
  if (forceUpdate != true && languages.isNotEmpty) {
    return languages;
  }

  DocumentSnapshot<dynamic>? languagesDoc;
  try {
    final languagesCollection = FirebaseFirestore.instance.collection('languages');
    languagesDoc = await languagesCollection.doc('languages').get();
  } catch (err) {
    final assetsLanguages = await rootBundle.loadString('assets/languages/languages.json');
    Map<String, dynamic> languagesRawData = await jsonDecodeIsolate(assetsLanguages);
    for (var id in languagesRawData.keys) {
      languages[id] = languagesRawData[id];
    }
    return languages;
  }

  final languagesRawData = languagesDoc.data();

  if (!languagesDoc.exists || languagesRawData == null) {
    recordError(
      const CustomError(code: 404, message: 'Can\'t retrieve languages from FireStore'),
      StackTrace.current,
    );
    return null;
  }

  Map<String, dynamic>? languagesData;
  try {
    languagesData = await jsonDecodeIsolate(languagesRawData['raw']);
  } catch (err, stack) {
    recordError(err, stack);
    return null;
  }

  if (languagesData == null) {
    return null;
  }

  final languagesPath = await _getLanguagesPath();
  File file = File('$languagesPath/languages');
  file = await file.create(recursive: true);
  await file.writeAsString(await jsonEncodeIsolate(languagesRawData));

  languages.clear();
  for (var id in languagesData.keys) {
    languages[id] = languagesData[id];
  }

  return languages;
}

Future<String> _getLanguagesPath() async {
  final documentsPath = await getDocumentsPath();
  return '${documentsPath}languages';
}