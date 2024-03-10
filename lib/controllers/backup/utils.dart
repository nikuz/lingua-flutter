import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/controllers/dictionary/constants.dart';

class BackupInfo {
  final String? filePath;
  final int wordsAmount;

  const BackupInfo({
    required this.filePath,
    required this.wordsAmount,
  });
}

Future<String?> getBackupFilePath(String? fileIdentifier) async {
  String? backupFilePath;
  if (fileIdentifier != null) {
    // try to access previously saved backup
    try {
      backupFilePath = await FilePickerWritable().readFile(
        identifier: fileIdentifier,
        reader: _onRestoreFileOpened,
      );
    } catch(err) {
      //
    }
  }

  // if previously saved backup is not available anymore
  backupFilePath ??= await FilePickerWritable().openFile(_onRestoreFileOpened);

  return backupFilePath;
}

Future<BackupInfo?> getBackupFileInfo(String? fileIdentifier) async {
  final backupFilePath = await getBackupFilePath(fileIdentifier);
  final databaseReg = RegExp(r'\.SQLITE3$');
  int wordsAmount = 0;

  if (backupFilePath != null) {
    // check if database file exists in the archive
    InputFileStream input = InputFileStream(backupFilePath);
    final files = TarDecoder().decodeBuffer(input);
    final dataBaseFile = files.firstWhereOrNull((item) => databaseReg.firstMatch(item.name) != null);
    if (dataBaseFile != null && dataBaseFile.isFile) {
      // extract database file from the archive
      final documentsPath = await getDocumentsPath();
      final filePath = '$documentsPath${dataBaseFile.name}.tmp';

      File outFile = File(filePath);
      outFile = await outFile.create(recursive: true);
      await outFile.writeAsBytes(dataBaseFile.content);

      // open database file and read dictionary length
      final db = await openDatabase(outFile.path, version: 1);
      const countColumnName = 'COUNT(id)';
      final List<Map> results = await db.rawQuery('SELECT $countColumnName FROM ${DictionaryControllerConstants.databaseTableName}');
      wordsAmount = results[0][countColumnName];
      await db.close();

      // remove temporary database file
      outFile.deleteSync();
    }
  }

  return BackupInfo(
    filePath: backupFilePath,
    wordsAmount: wordsAmount,
  );
}

Future<void> removeTemporaryBackupFile(String backupFilePath) async {
  final backupFile = File(backupFilePath);
  if (backupFile.existsSync()) {
    backupFile.deleteSync();
  }
}

Future<String> _onRestoreFileOpened(FileInfo fileInfo, File backupFile) async {
  if (fileInfo.fileName?.contains('.wisual') != true) {
    throw 'Selected backup file is not supported';
  }

  final documentsPath = await getDocumentsPath();
  final backupFilePath = '$documentsPath${fileInfo.fileName}';
  backupFile.copySync(backupFilePath);

  return backupFilePath;
}