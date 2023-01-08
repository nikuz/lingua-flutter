import 'dart:io';
import 'dart:isolate';
import 'dart:developer' as developer;
import 'package:archive/archive_io.dart';
import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/app_config.dart' as config;

Future<String?> create({
  String? fileIdentifier,
}) async {
  final documentsPath = await getDocumentsPath();
  final dbPath = await getDbPath();
  const backupFileName = '${config.appName}-backup.wisual';
  final receivePort = ReceivePort();

  await Isolate.spawn(
    _createBackupArchive,
    CreateBackupArchiveParams(
      documentsPath: documentsPath,
      dbPath: dbPath,
      backupFileName: backupFileName,
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

Future<String?> restore({
  String? fileIdentifier,
}) async {
  FileInfo? backupFileInfo;
  if (fileIdentifier != null) {
    // try to access previously saved backup
    try {
      backupFileInfo = await FilePickerWritable().readFile(
        identifier: fileIdentifier,
        reader: _onRestoreFileOpened,
      );
    } catch(err) {
      //
    }
  }

  // if previously saved backup is not available anymore
  backupFileInfo ??= await FilePickerWritable().openFile(_onRestoreFileOpened);

  if (backupFileInfo == null) {
    developer.log('No backup file selected');
  }

  return backupFileInfo?.identifier;
}

class CreateBackupArchiveParams {
  final String documentsPath;
  final String dbPath;
  final String backupFileName;
  final SendPort sendPort;

  const CreateBackupArchiveParams({
    required this.documentsPath,
    required this.dbPath,
    required this.backupFileName,
    required this.sendPort
  });
}

Future<FileInfo> _onRestoreFileOpened(FileInfo fileInfo, backupFile) async {
  if (fileInfo.fileName?.endsWith('.wisual') != true) {
    throw 'Not supported backup file';
  }
  final documentsPath = await getDocumentsPath();
  final dbPath = await getDbPath();
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _restoreFilesFromBackupArchive,
    DecodeBackupArchiveParams(
      documentsPath: documentsPath,
      dbPath: dbPath,
      backupFilePath: backupFile.path,
      sendPort: receivePort.sendPort,
    ),
    onError: receivePort.sendPort,
  );

  final restoreIsSuccessful = await receivePort.first;
  if (restoreIsSuccessful is! bool) {
    throw 'Can\'t restore backup from provided file';
  }

  return fileInfo;
}

Future<void> _createBackupArchive(CreateBackupArchiveParams params) async {
  final backupFilePath = '${params.documentsPath}${params.backupFileName}';
  final encoder = TarFileEncoder();
  encoder.create(backupFilePath);

  final databaseDirectory = Directory('${params.dbPath}database');
  await encoder.addDirectory(databaseDirectory);

  final pronunciationsDirectory = Directory('${params.documentsPath}pronunciations');
  if (pronunciationsDirectory.existsSync()) {
    await encoder.addDirectory(pronunciationsDirectory);
  }

  final imagesDirectory = Directory('${params.documentsPath}images');
  if (imagesDirectory.existsSync()) {
    await encoder.addDirectory(imagesDirectory);
  }

  await encoder.close();

  Isolate.exit(params.sendPort, backupFilePath);
}

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

Future<void> _restoreFilesFromBackupArchive(DecodeBackupArchiveParams params) async {
  InputFileStream input = InputFileStream(params.backupFilePath);
  final files = TarDecoder().decodeBuffer(input);
  for (var file in files) {
    if (file.name.contains('database') || file.name.contains('images') || file.name.contains('pronunciations')) {
      String filePath = '${params.documentsPath}${file.name}';
      if (file.name.contains('SQLITE3')) {
        filePath = '${params.dbPath}${file.name}';
      }
      if (file.isFile) {
        File outFile = File(filePath);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }
  }
  input.close();
  Isolate.exit(params.sendPort, true);
}