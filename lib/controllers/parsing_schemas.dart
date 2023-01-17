import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lingua_flutter/providers/error_logger.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/json.dart';
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
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

    // decode file JSON content
    Map<String, dynamic>? schemaData;
    try {
      schemaData = await jsonDecodeIsolate(schemaFileContent);
    } catch (err, stack) {
      recordError(err, stack);
    }

    // create schema class instance and store in parsingSchemas cache variable
    if (schemaData != null) {
      StoredParsingSchema? schema;
      // schemas can be outdated and trying to parse them with current StoredParsingSchema structure throws error
      // TODO: avoid this situation by improving "fromFirestore" parsing method
      try {
        final schemaJson = await jsonDecodeIsolate(schemaData['schema']);
        schema = StoredParsingSchema.fromFirestore(schemaData, schemaJson);
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

  final schemas = FirebaseFirestore.instance.collection('schemas');
  final schemaDoc = await schemas.doc(versionName).get();
  final schemaData = schemaDoc.data();

  if (!schemaDoc.exists || schemaData == null) {
    return null;
  }

  final schemaJson = await jsonDecodeIsolate(schemaData['schema']);
  final schema = StoredParsingSchema.fromFirestore(schemaData, schemaJson);
  final schemasPath = await _getSchemasPath();
  final schemaDataJson = await jsonEncodeIsolate(schemaData);

  // store schema with "schema.version" name
  parsingSchemas[schema.version] = schema;
  File file = File('$schemasPath/${schema.version}');
  file = await file.create(recursive: true);
  await file.writeAsString(schemaDataJson);

  return schema;
}

Future<String> _getSchemasPath() async {
  final documentsPath = await getDocumentsPath();
  return '${documentsPath}schemas';
}