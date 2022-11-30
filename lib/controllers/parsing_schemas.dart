import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';

export 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';

Map<String, StoredParsingSchema> parsingSchemas = Map();

Future<void> preloadLocalParsingSchemas() async {
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
      final schema = StoredParsingSchema.fromFirestore(schemaData);
      parsingSchemas[schema.version] = schema;
      if (schema.current) {
        parsingSchemas['current'] = schema;
      }
    }
  }
}

Future<StoredParsingSchema?> getParsingSchema(String versionName, [ bool? forceUpdate ]) async {
  if (forceUpdate != true && parsingSchemas[versionName] != null) {
    return parsingSchemas[versionName];
  }

  final schemas = FirebaseFirestore.instance.collection('schemas');
  final schemaDoc = await schemas.doc(versionName).get();

  if (!schemaDoc.exists) {
    return null;
  }

  print(schemas.doc(versionName).get());

  final schemaData = schemaDoc.data();
  if (schemaData == null) {
    return null;
  }

  final schema = StoredParsingSchema.fromFirestore(schemaData);
  parsingSchemas[schema.version] = schema;
  final schemasPath = await _getSchemasPath();
  final file = File('$schemasPath/$versionName');
  await file.writeAsString(jsonEncode(schemaData));

  return schema;
}

Future<String> _getSchemasPath() async {
  final documentsPath = await getDocumentsPath();
  return '$documentsPath/schemas';
}