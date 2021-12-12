import 'dart:io';
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

import 'package:lingua_flutter/app_config.dart';
import 'package:lingua_flutter/utils/files.dart';

import 'events.dart';
import 'state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SharedPreferences prefs;

  SettingsBloc({ required this.prefs }) : super(SettingsUninitialized()) {
    on<SettingsGet>((event, emit) {
      final bool pronunciationAutoPlay = prefs.getBool('pronunciationAutoPlay') ?? true;
      final bool darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
      final bool autoDarkMode = prefs.getBool('autoDarkMode') ?? false;
      final bool offlineMode = prefs.getBool('offlineMode') ?? false;
      final int? offlineDictionaryUpdateTime = prefs.getInt('offlineDictionaryUpdateTime');
      final int? offlineDictionaryUpdateSize = prefs.getInt('offlineDictionaryUpdateSize');
      emit(SettingsLoaded({
        'pronunciationAutoPlay': pronunciationAutoPlay,
        'darkModeEnabled': darkModeEnabled,
        'autoDarkMode': autoDarkMode,
        'offlineDictionaryUpdateTime': offlineDictionaryUpdateTime,
        'offlineDictionaryUpdateSize': offlineDictionaryUpdateSize,
        'offlineMode': offlineMode,
        'offlineDictionaryPreUpdateSize': null,
        'offlineDictionaryUpdateLoading': false,
        'offlineDictionaryUpdateError': false,
        'offlineDictionaryClearLoading': false,
        'offlineDictionaryClearConfirmation': false,
      }));
    });

    on<SettingsChange>((event, emit) async {
      final SettingsState currentState = state;
      if (currentState is SettingsLoaded) {
        if (event.savePrefs) {
          switch (event.type) {
            case 'bool':
              await prefs.setBool(event.id, event.value);
              break;
            case 'String':
              await prefs.setString(event.id, event.value);
              break;
            case 'int':
              await prefs.setInt(event.id, event.value);
              break;
          }
        }

        emit(
            currentState.copyWith([{
              'id': event.id,
              'value': event.value,
            }])
        );
      }
    });

    on<SettingsDownloadDictionaryInfo>((event, emit) async {
      final SettingsState currentState = state;
      if (currentState is SettingsLoaded) {
        emit(currentState.copyWith([{
          'id': 'offlineDictionaryUpdateLoading',
          'value': true,
        }]));
        final Map<String, dynamic> stopLoading = {
          'id': 'offlineDictionaryUpdateLoading',
          'value': false,
        };

        try {
          String dir = await getDocumentsPath();
          drive.File backupFile = await _getBackupInfo(dir);

          if (backupFile != null) {
            emit(currentState.copyWith([{
              'id': 'offlineDictionaryPreUpdateSize',
              'value': backupFile.fileSize,
            }, stopLoading]));
          } else {
            emit(currentState.copyWith([{
              'id': 'offlineDictionaryUpdateError',
              'value': true,
            }, stopLoading]));
          }
        } catch (e, s) {
          print(e);
          print(s);
          emit(currentState.copyWith([{
            'id': 'offlineDictionaryUpdateError',
            'value': true,
          }, stopLoading]));
        }
      }
    });

    on<SettingsDownloadDictionary>((event, emit) async {
      final SettingsState currentState = state;
      if (currentState is SettingsLoaded) {
        emit(currentState.copyWith([{
          'id': 'offlineDictionaryUpdateLoading',
          'value': true,
        }, {
          'id': 'offlineDictionaryPreUpdateSize',
          'value': null,
        }]));
        final Map<String, dynamic> stopLoading = {
          'id': 'offlineDictionaryUpdateLoading',
          'value': false,
        };

        try {
          String dir = await getDocumentsPath();
          File? backupFile = await _downloadBackup(dir);

          if (backupFile != null) {
            var bytes = backupFile.readAsBytesSync();
            var archive = ZipDecoder().decodeBytes(bytes);
            for (var file in archive) {
              var fileName = '$dir/${file.name}';
              if (file.isFile) {
                var outFile = File(fileName);
                outFile = await outFile.create(recursive: true);
                await outFile.writeAsBytes(file.content);
              }
            }

            const String timeId = 'offlineDictionaryUpdateTime';
            final int timeValue = new DateTime.now().millisecondsSinceEpoch;
            const String sizeId = 'offlineDictionaryUpdateSize';
            final int sizeValue = await backupFile.length();

            backupFile.delete();

            await prefs.setInt(timeId, timeValue);
            await prefs.setInt(sizeId, sizeValue);
            emit(currentState.copyWith([{
              'id': timeId,
              'value': timeValue,
            }, {
              'id': sizeId,
              'value': sizeValue,
            }, stopLoading]));
          } else {
            emit(currentState.copyWith([{
              'id': 'offlineDictionaryUpdateError',
              'value': true,
            }, stopLoading]));
          }
        } catch (e, s) {
          print(e);
          print(s);
          emit(currentState.copyWith([{
            'id': 'offlineDictionaryUpdateError',
            'value': true,
          }, stopLoading]));
        }
      }
    });

    on<SettingsClearDictionary>((event, emit) async {
      final SettingsState currentState = state;
      if (currentState is SettingsLoaded) {
        emit(currentState.copyWith([{
          'id': 'offlineDictionaryClearLoading',
          'value': true,
        }, {
          'id': 'offlineDictionaryClearConfirmation',
          'value': false,
        }, {
          'id': 'offlineMode',
          'value': false,
        }]));

        String dir = await getDocumentsPath();
        final database = Directory('$dir/database');
        if (database.existsSync()) {
          database.deleteSync(recursive: true);
        }
        final images = Directory('$dir/images');
        if (images.existsSync()) {
          images.deleteSync(recursive: true);
        }
        final pronunciations = Directory('$dir/pronunciations');
        if (pronunciations.existsSync()) {
          pronunciations.deleteSync(recursive: true);
        }

        await prefs.remove('offlineDictionaryUpdateTime');
        await prefs.remove('offlineDictionaryUpdateSize');
        await prefs.remove('offlineMode');

        emit(currentState.copyWith([{
          'id': 'offlineDictionaryClearLoading',
          'value': false,
        }, {
          'id': 'offlineDictionaryUpdateTime',
          'value': null,
        }, {
          'id': 'offlineDictionaryUpdateSize',
          'value': null,
        }]));
      }
    });
  }

  Future<dynamic> _getBackupInfo(String dir) async {
    final _credentials = new ServiceAccountCredentials.fromJson(googleApiCredentials);

    final scopes = [drive.DriveApi.driveScope];

    return clientViaServiceAccount(_credentials, scopes).then((client) {
      var api = new drive.DriveApi(client);
      return api.files.list().then((files) {
        Completer completer = new Completer();
        bool fileExists = false;
        for (var file in files.items!) {
          if (file.originalFilename == offlineDictionaryFileName) {
            fileExists = true;
            completer.complete(file);
            break;
          }
        }

        if (!fileExists) {
          completer.completeError('No file');
        }

        return completer.future;
      });
    });
  }

  Future<File?> _downloadBackup(String dir) async {
    final _credentials = new ServiceAccountCredentials.fromJson(googleApiCredentials);

    final scopes = [drive.DriveApi.driveScope];
    drive.File backupFile = await _getBackupInfo(dir);

    if (backupFile != null) {
      return clientViaServiceAccount(_credentials, scopes).then((client) {
        return client.readBytes(Uri.parse(backupFile.downloadUrl!)).then((bytes) {
          var file = new File('$dir/$offlineDictionaryFileName');
          return file.writeAsBytes(bytes);
        });
      });
    }

    return null;
  }
}
