import 'dart:io';
import 'dart:isolate';
import 'dart:developer' as developer;
import 'package:archive/archive_io.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/files.dart';

import './constants.dart';

class CreateBackupArchiveParams {
  final String documentsPath;
  final String dbPath;
  final SendPort sendPort;

  const CreateBackupArchiveParams({
    required this.documentsPath,
    required this.dbPath,
    required this.sendPort
  });
}

Future<String?> create(String? fileIdentifier) async {
  final documentsPath = await getDocumentsPath();
  final dbPath = await getDbPath();
  final receivePort = ReceivePort();

  // optimize local database
  await DBProvider().rawQuery('VACUUM;');

  await Isolate.spawn(
    _createBackupArchive,
    CreateBackupArchiveParams(
      documentsPath: documentsPath,
      dbPath: dbPath,
      sendPort: receivePort.sendPort,
    ),
    onError: receivePort.sendPort,
  );
  final backupFilePath = await receivePort.first;

  // String pathname is expected. If received different type, then interrupt further execution
  if (backupFilePath is! String) {
    return null;
  }

  final backupFile = File(backupFilePath);
  FileInfo? backupDestinationFile;
  if (fileIdentifier != null) {
    // try to write to previously created backup file
    try {
      backupDestinationFile = await FilePickerWritable().writeFileWithIdentifier(fileIdentifier, backupFile);
    } catch (err) {
      //
    }
  }

  // if previously created backup file is not available, request creating a new one
  backupDestinationFile ??= await FilePickerWritable().openFileForCreate(
    fileName: backupFileName,
    writer: (destinationBackupFile) async {
      await destinationBackupFile.writeAsBytes(await backupFile.readAsBytes());
      await backupFile.delete();
    },
  );

  if (backupDestinationFile == null) {
    developer.log('No new backup file is created');
  }

  return backupDestinationFile?.identifier;
}

Future<void> _createBackupArchive(CreateBackupArchiveParams params) async {
  final backupFilePath = '${params.documentsPath}$backupFileName';
  final encoder = TarFileEncoder();
  encoder.create(backupFilePath);

  final databaseDirectory = Directory('${params.dbPath}database');
  await encoder.addDirectory(databaseDirectory);

  for (var item in assetsDirectories) {
    final dir = Directory('${params.documentsPath}$item');
    if (dir.existsSync()) {
      await encoder.addDirectory(dir);
    }
  }

  await encoder.close();

  Isolate.exit(params.sendPort, backupFilePath);
}