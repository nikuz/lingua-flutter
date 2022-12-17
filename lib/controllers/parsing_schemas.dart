import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/app_config.dart';

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
      schemaData = jsonDecode(schemaFileContent);
    } catch (err, stack) {
      FirebaseCrashlytics.instance.recordError(err, stack);
    }

    // create schema class instance and store in parsingSchemas cache variable
    if (schemaData != null) {
      StoredParsingSchema? schema;
      // schemas can be outdated and trying to parse them with current StoredParsingSchema structure throws error
      try {
        schema = StoredParsingSchema.fromFirestore(schemaData);
      } catch (e) {
        //
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
    if (versionName != 'current' || versionNumber >= minCurrentParsingSchema) {
      return parsingSchemas[versionName];
    }
  }

  final schemas = FirebaseFirestore.instance.collection('schemas');
  final schemaDoc = await schemas.doc(versionName).get();

  if (!schemaDoc.exists) {
    return null;
  }

  final schemaData = schemaDoc.data();
  if (schemaData == null) {
    return null;
  }

  final schema = StoredParsingSchema.fromFirestore(schemaData);
  final schemasPath = await _getSchemasPath();
  final schemaJson = jsonEncode(schemaData);

  // store schema with "schema.version" name
  parsingSchemas[schema.version] = schema;
  final file = File('$schemasPath/${schema.version}');
  await file.writeAsString(schemaJson);

  // if "current" schema was retrieved, then it's version will not match the "versionName" variable it was requested with,
  // so we also store file with "versionName" file name
  if (versionName != schema.version) {
    parsingSchemas[versionName] = schema;
    final file = File('$schemasPath/$versionName');
    await file.writeAsString(schemaJson);
  }

  return schema;
}

Future<String> _getSchemasPath() async {
  final documentsPath = await getDocumentsPath();
  return '${documentsPath}schemas';
}