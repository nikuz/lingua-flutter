import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive_io.dart';
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/files.dart';

import './constants.dart';
import './utils.dart';

class DecodeBackupArchiveParams {
  final String documentsPath;
  final String dbPath;
  final String backupFilePath;
  final SendPort sendPort;

  const DecodeBackupArchiveParams({
    required this.documentsPath,
    required this.dbPath,
    required this.backupFilePath,
    required this.sendPort
  });
}

Future<void> restore(String backupFilePath) async {
  final documentsPath = await getDocumentsPath();
  final dbPath = await getDbPath();
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _restoreFilesFromBackupArchive,
    DecodeBackupArchiveParams(
      documentsPath: documentsPath,
      dbPath: dbPath,
      backupFilePath: backupFilePath,
      sendPort: receivePort.sendPort,
    ),
    onError: receivePort.sendPort,
  );

  final restoreIsSuccessful = await receivePort.first;

  await removeTemporaryBackupFile(backupFilePath);

  if (restoreIsSuccessful is! bool) {
    throw 'Can\'t restore backup from provided file';
  }
}

Future<void> _restoreFilesFromBackupArchive(DecodeBackupArchiveParams params) async {
  // cleanup all the assetsDirectories
  for (var item in assetsDirectories) {
    final dir = Directory('${params.documentsPath}$item');
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }

  InputFileStream input = InputFileStream(params.backupFilePath);
  final files = TarDecoder().decodeBuffer(input);
  for (var file in files) {
    bool isValid = true;
    for (var dir in assetsDirectories) {
      if (!file.name.contains(dir)) {
        isValid = false;
      }
    }
    if (isValid && file.isFile) {
      String filePath = '${params.documentsPath}${file.name}';
      final isDatabaseFile = file.name.contains('SQLITE3');
      if (isDatabaseFile) {
        filePath = '${params.dbPath}${file.name}';
      }
      File outFile = File(filePath);
      outFile = await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content);
    }
  }
  input.close();
  Isolate.exit(params.sendPort, true);
}