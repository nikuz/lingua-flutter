import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:archive/archive.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

import 'package:lingua_flutter/app_config.dart';
import 'package:lingua_flutter/google-api-credentials.dart';
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/files.dart';
import 'package:lingua_flutter/utils/types.dart';

import './settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SharedPreferences prefs;

  SettingsCubit(this.prefs) : super(SettingsState.initial(prefs));

  void setPronunciationAutoPlay(bool value) async {
    await prefs.setBool('pronunciationAutoPlay', value);
    emit(state.copyWith(
      pronunciationAutoPlay: value,
    ));
  }

  void setDarkMode(bool value) async {
    await prefs.setBool('darkMode', value);
    emit(state.copyWith(
      darkMode: value,
    ));
  }

  void setAutoDarkMode(bool value) async {
    await prefs.setBool('autoDarkMode', value);
    emit(state.copyWith(
      autoDarkMode: value,
    ));
  }

  void clearBackupError() {
    emit(state.copyWith(
      backupError: false,
    ));
  }

  void clearBackupPreloadSize() {
    emit(state.copyWith(
      backupPreloadSize: Wrapped.value(null),
    ));
  }

  void getBackupInfo() async {
    emit(state.copyWith(
      backupLoading: true,
      backupPreloadSize: null,
    ));

    try {
      final String dir = await getDocumentsPath();
      final drive.File backupFile = await _getBackupInfo(dir);

      emit(state.copyWith(
        backupLoading: false,
        backupPreloadSize: Wrapped.value(
          backupFile.fileSize != null ? int.parse(backupFile.fileSize!) : null
        ),
      ));
    } catch (e) {
      print(e);
      emit(state.copyWith(
        backupLoading: false,
        backupError: true,
      ));
    }
  }

  void downloadBackup() async {
    emit(state.copyWith(
      backupLoading: true,
      backupPreloadSize: Wrapped.value(null)
    ));

    try {
      final documentsPath = await getDocumentsPath();
      final databasePath = await getDatabasesPath();
      final File? backupFile = await _downloadBackup(documentsPath);

      if (backupFile != null) {
        final bytes = backupFile.readAsBytesSync();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (var file in archive) {
          var fileName = '$documentsPath/${file.name}';
          if (file.name.indexOf('SQLITE3') != -1) {
            fileName = '$databasePath/${file.name}';
          }
          if (file.isFile) {
            var outFile = File(fileName);
            outFile = await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content);
          }
        }

        final int timeValue = new DateTime.now().millisecondsSinceEpoch;
        final int sizeValue = await backupFile.length();

        backupFile.delete();

        await prefs.setInt('backupTime', timeValue);
        await prefs.setInt('backupSize', sizeValue);
        emit(state.copyWith(
          backupTime: timeValue,
          backupSize: sizeValue,
          backupLoading: false,
        ));
      } else {
        emit(state.copyWith(
          backupError: true,
          backupLoading: false,
        ));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(
        backupError: true,
        backupLoading: false,
      ));
    }
  }
}

Future<dynamic> _getBackupInfo(String dir) async {
  final _credentials = new ServiceAccountCredentials.fromJson(googleApiCredentials);

  final scopes = [drive.DriveApi.driveScope];

  return clientViaServiceAccount(_credentials, scopes).then((client) {
    final api = new drive.DriveApi(client);
    return api.files.list().then((files) {
      final Completer completer = new Completer();
      bool fileExists = false;

      if (files.items != null) {
        for (var file in files.items!) {
          if (file.originalFilename == backupFileName) {
            fileExists = true;
            completer.complete(file);
            break;
          }
        }
      }

      if (!fileExists) {
        completer.completeError(Exception('No file'));
      }

      return completer.future;
    });
  });
}

Future<File?> _downloadBackup(String dir) async {
  final _credentials = new ServiceAccountCredentials.fromJson(googleApiCredentials);

  final scopes = [drive.DriveApi.driveScope];
  final drive.File backupFile = await _getBackupInfo(dir);

  if (backupFile.downloadUrl != null) {
    return clientViaServiceAccount(_credentials, scopes).then((client) {
      return client.readBytes(Uri.parse(backupFile.downloadUrl!)).then((bytes) {
        final file = new File('$dir/$backupFileName');
        return file.writeAsBytes(bytes);
      });
    });
  }

  return null;
}