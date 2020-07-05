import 'dart:io';
import 'dart:async';
import 'package:meta/meta.dart';
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

  SettingsBloc({@required this.prefs}) : assert(prefs is SharedPreferences);

  @override
  SettingsState get initialState => SettingsUninitialized();

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    final currentState = state;
    if (event is SettingsGet) {
      final bool pronunciationAutoPlay = prefs.getBool('pronunciationAutoPlay') ?? true;
      final bool offlineMode = prefs.getBool('offlineMode') ?? false;
      final int offlineDictionaryUpdateTime = prefs.getInt('offlineDictionaryUpdateTime');
      final int offlineDictionaryUpdateSize = prefs.getInt('offlineDictionaryUpdateSize');
      yield SettingsLoaded({
        'pronunciationAutoPlay': pronunciationAutoPlay,
        'offlineDictionaryUpdateTime': offlineDictionaryUpdateTime,
        'offlineDictionaryUpdateSize': offlineDictionaryUpdateSize,
        'offlineMode': offlineMode,
        'offlineDictionaryPreUpdateSize': null,
        'offlineDictionaryUpdateLoading': false,
        'offlineDictionaryUpdateError': false,
        'offlineDictionaryClearLoading': false,
        'offlineDictionaryClearConfirmation': false,
      });
    } else if (event is SettingsChange) {
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

        yield currentState.copyWith([{
          'id': event.id,
          'value': event.value,
        }]);
      }
    } else if (event is SettingsDownloadDictionaryInfo) {
      if (currentState is SettingsLoaded) {
        yield currentState.copyWith([{
          'id': 'offlineDictionaryUpdateLoading',
          'value': true,
        }]);
        final Map<String, dynamic> stopLoading = {
          'id': 'offlineDictionaryUpdateLoading',
          'value': false,
        };

        try {
          String dir = await getDocumentsPath();
          drive.File backupFile = await _getBackupInfo(dir);

          if (backupFile != null) {
            yield currentState.copyWith([{
              'id': 'offlineDictionaryPreUpdateSize',
              'value': backupFile.fileSize,
            }, stopLoading]);
          } else {
            yield currentState.copyWith([{
              'id': 'offlineDictionaryUpdateError',
              'value': true,
            }, stopLoading]);
          }
        } catch (e, s) {
          print(e);
          print(s);
          yield currentState.copyWith([{
            'id': 'offlineDictionaryUpdateError',
            'value': true,
          }, stopLoading]);
        }
      }
    } else if (event is SettingsDownloadDictionary) {
      if (currentState is SettingsLoaded) {
        yield currentState.copyWith([{
          'id': 'offlineDictionaryUpdateLoading',
          'value': true,
        }, {
          'id': 'offlineDictionaryPreUpdateSize',
          'value': null,
        }]);
        final Map<String, dynamic> stopLoading = {
          'id': 'offlineDictionaryUpdateLoading',
          'value': false,
        };

        try {
          String dir = await getDocumentsPath();
          File backupFile = await _downloadBackup(dir);

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
            yield currentState.copyWith([{
              'id': timeId,
              'value': timeValue,
            }, {
              'id': sizeId,
              'value': sizeValue,
            }, stopLoading]);
          } else {
            yield currentState.copyWith([{
              'id': 'offlineDictionaryUpdateError',
              'value': true,
            }, stopLoading]);
          }
        } catch (e, s) {
          print(e);
          print(s);
          yield currentState.copyWith([{
            'id': 'offlineDictionaryUpdateError',
            'value': true,
          }, stopLoading]);
        }
      }
    } else if (event is SettingsClearDictionary) {
      if (currentState is SettingsLoaded) {
        yield currentState.copyWith([{
          'id': 'offlineDictionaryClearLoading',
          'value': true,
        }, {
          'id': 'offlineDictionaryClearConfirmation',
          'value': false,
        }, {
          'id': 'offlineMode',
          'value': false,
        }]);

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

        yield currentState.copyWith([{
          'id': 'offlineDictionaryClearLoading',
          'value': false,
        }, {
          'id': 'offlineDictionaryUpdateTime',
          'value': null,
        }, {
          'id': 'offlineDictionaryUpdateSize',
          'value': null,
        }]);
      }
    }
  }

  Future<dynamic> _getBackupInfo(String dir) async {
    final _credentials = new ServiceAccountCredentials.fromJson(googleApiCredentials);

    final scopes = [drive.DriveApi.DriveScope];

    return clientViaServiceAccount(_credentials, scopes).then((client) {
      var api = new drive.DriveApi(client);
      return api.files.list().then((files) {
        Completer completer = new Completer();
        bool fileExists = false;
        for (var file in files.items) {
          if (file.originalFilename == offlineDictionaryFileName) {
            fileExists = true;
            completer.complete(file);
          }
        }

        if (!fileExists) {
          completer.completeError('No file');
        }

        return completer.future;
      });
    });
  }

  Future<File> _downloadBackup(String dir) async {
    final _credentials = new ServiceAccountCredentials.fromJson(googleApiCredentials);

    final scopes = [drive.DriveApi.DriveScope];
    drive.File backupFile = await _getBackupInfo(dir);

    if (backupFile != null) {
      return clientViaServiceAccount(_credentials, scopes).then((client) {
        return client.readBytes(backupFile.downloadUrl).then((bytes) {
          var file = new File('$dir/$offlineDictionaryFileName');
          return file.writeAsBytes(bytes);
        });
      });
    }

    return null;
  }
}
