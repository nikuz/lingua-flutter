import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lingua_flutter/controllers/api/api.dart';
import 'package:lingua_flutter/controllers/error_logger/error_logger.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/json.dart';
import 'package:lingua_flutter/app_config.dart' as config;

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
      languagesData = await jsonDecodeIsolate(languagesFileContent);
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

  Map<String, dynamic>? languagesResponse;
  try {
    final response = await apiGet(
      url: '${config.getApiUrl()}/api/languages',
      options: Options(
        contentType: 'application/json',
        headers: {
          'accept-encoding': 'gzip, deflate',
        },
      ),
    );
    languagesResponse = response.data;
  } catch (err) {
    final assetsLanguages = await rootBundle.loadString('assets/languages/languages.json');
    Map<String, dynamic> languagesRawData = await jsonDecodeIsolate(assetsLanguages);
    for (var id in languagesRawData.keys) {
      languages[id] = languagesRawData[id];
    }
    return languages;
  }

  if (languagesResponse == null) {
    return null;
  }

  final languagesPath = await _getLanguagesPath();
  File file = File('$languagesPath/languages');
  file = await file.create(recursive: true);
  await file.writeAsString(await jsonEncodeIsolate(languagesResponse));

  languages.clear();
  for (var id in languagesResponse.keys) {
    languages[id] = languagesResponse[id];
  }

  return languages;
}

Future<String> _getLanguagesPath() async {
  final documentsPath = await getDocumentsPath();
  return '${documentsPath}languages';
}