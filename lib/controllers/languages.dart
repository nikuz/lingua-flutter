import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lingua_flutter/providers/error_logger.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/models/error.dart';

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
      Map<String, dynamic> languagesRawData = jsonDecode(languagesFileContent);
      languagesData = jsonDecode(languagesRawData['raw']);
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

  final languagesCollection = FirebaseFirestore.instance.collection('languages');
  final languagesDoc = await languagesCollection.doc('languages').get();
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
    languagesData = jsonDecode(languagesRawData['raw']);
  } catch (err, stack) {
    recordError(err, stack);
    return null;
  }

  if (languagesData == null) {
    return null;
  }

  final languagesPath = await _getLanguagesPath();
  final file = File('$languagesPath/languages');
  await file.writeAsString(jsonEncode(languagesRawData));

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