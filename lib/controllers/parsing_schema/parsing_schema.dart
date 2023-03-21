import 'dart:io';
import 'package:lingua_flutter/controllers/request/request.dart' as request_controller;
import 'package:lingua_flutter/controllers/request/request.dart' show Options;
import 'package:lingua_flutter/controllers/error_logger/error_logger.dart';
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/crypto.dart';
import 'package:lingua_flutter/utils/json.dart';
import 'package:lingua_flutter/app_config.dart' as config;

export 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';

final Map<String, StoredParsingSchema> parsingSchemas = {};

Future<void> preload() async {
  final schemasPath = await _getSchemasPath();
  final schemasDir = Directory(schemasPath);

  if (!(await schemasDir.exists())) {
    await schemasDir.create();
  }

  await for (var item in schemasDir.list()) {
    // read schema file
    final file = File(item.path);
    final schemaFileContent = await file.readAsString();
    String? decryptedFileContent;
    try {
      decryptedFileContent = decrypt(schemaFileContent);
    } catch (err, stack) {
      file.deleteSync();
      recordError(err, stack);
    }

    // decode file JSON content
    Map<String, dynamic>? schemaData;
    if (decryptedFileContent != null) {
      try {
        schemaData = await jsonDecodeIsolate(decryptedFileContent);
      } catch (err, stack) {
        recordError(err, stack);
      }
    }

    // create schema class instance and store in parsingSchemas cache variable
    if (schemaData != null) {
      StoredParsingSchema? schema;
      // schemas can be outdated and trying to parse them with current StoredParsingSchema structure throws error
      // TODO: avoid this situation by improving "fromCloud" parsing method
      try {
        schema = StoredParsingSchema.fromCloud(schemaData, schemaData['schema']);
      } catch (err, stack) {
        // if we remove the file here, then the user won't be able to parse previously saved words
        // and the words will be downloaded again and needed to be updated with a new parsing schema version
        file.deleteSync();
        recordError(err, stack);
      }
      if (schema != null) {
        parsingSchemas[schema.version] = schema;
        if (schema.current) {
          parsingSchemas['current'] = schema;
        }
      }
    }
  }
}

Future<StoredParsingSchema?> get(String versionName, { bool? forceUpdate }) async {
  if (forceUpdate != true && parsingSchemas[versionName] != null) {
    int versionNumber = int.parse(parsingSchemas[versionName]!.version);

    // check that version of "current" schema is more or equal minimum acceptable
    if (versionName != 'current' || versionNumber >= config.minCurrentParsingSchema) {
      return parsingSchemas[versionName];
    }
  }

  try {
    final response = await request_controller.get(
      url: '${config.getApiUrl()}/api/schema/current',
      options: Options(
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
        headers: {
          'accept-encoding': 'gzip, deflate',
        },
      ),
    );

    final decryptedResult = decrypt(response.toString());
    final responseJson = await jsonDecodeIsolate(decryptedResult);

    final schemaJson = responseJson['schema'];
    final schema = StoredParsingSchema.fromCloud(responseJson, schemaJson);
    final schemasPath = await _getSchemasPath();

    // store schema with "schema.version" name
    parsingSchemas[schema.version] = schema;
    File file = File('$schemasPath/${schema.version}');
    file = await file.create(recursive: true);
    await file.writeAsString(response.toString());

    return schema;
  } catch (err, stack) {
    recordError(err, stack, information: {
      'message': 'Can\'t retrieve "current" parsing schema',
    });

    return null;
  }
}

Future<String> _getSchemasPath() async {
  final documentsPath = await getDocumentsPath();
  return '${documentsPath}schemas';
}