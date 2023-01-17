import 'dart:io';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:lingua_flutter/utils/files.dart';

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