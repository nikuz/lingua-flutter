import 'dart:io';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

import 'package:lingua_flutter/app_config.dart';

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
      print('SettingsGet');
      final bool pronunciationAutoPlay = prefs.getBool('pronunciationAutoPlay') ?? true;
      final int offlineDictionaryUpdateTime = prefs.getInt('offlineDictionaryUpdateTime');
      yield SettingsLoaded({
        'pronunciationAutoPlay': pronunciationAutoPlay,
        'offlineDictionaryUpdateTime': offlineDictionaryUpdateTime,
        'offlineDictionaryUpdateLoading': false,
        'offlineDictionaryUpdateError': false,
        'offlineDictionaryClearLoading': false,
      });
    } else if (event is SettingsChange) {
      if (currentState is SettingsLoaded) {
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

        yield currentState.copyWith([{
          'id': event.id,
          'value': event.value,
        }]);
      }
    } else if (event is SettingsDownloadDictionary) {
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
          String dir = (await getApplicationDocumentsDirectory()).path;
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

            backupFile.delete();

            const String id = 'offlineDictionaryUpdateTime';
            final int value = new DateTime.now().millisecondsSinceEpoch;

            await prefs.setInt(id, value);
            yield currentState.copyWith([{
              'id': id,
              'value': value,
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
    } else if (event is SettingsDownloadDictionaryHideError) {
      if (currentState is SettingsLoaded) {
        yield currentState.copyWith([{
          'id': 'offlineDictionaryUpdateError',
          'value': false,
        }]);
      }
    } else if (event is SettingsClearDictionary) {
      if (currentState is SettingsLoaded) {
        yield currentState.copyWith([{
          'id': 'offlineDictionaryClearLoading',
          'value': true,
        }]);

        String dir = (await getApplicationDocumentsDirectory()).path;
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

        yield currentState.copyWith([{
          'id': 'offlineDictionaryClearLoading',
          'value': false,
        }, {
          'id': 'offlineDictionaryUpdateTime',
          'value': null,
        }]);
      }
    }
  }

  Future<File> _downloadBackup(String dir) async {
    final _credentials = new ServiceAccountCredentials.fromJson(googleApiCredentials);

    final scopes = [drive.DriveApi.DriveScope];

    return clientViaServiceAccount(_credentials, scopes).then((client) {
      var api = new drive.DriveApi(client);
      return api.files.list().then((files) {
        for (var file in files.items) {
          if (file.originalFilename == offlineDictionaryFileName) {
            return client.readBytes(file.downloadUrl).then((bytes) {
              var file = new File('$dir/$offlineDictionaryFileName');
              return file.writeAsBytes(bytes);
            });
          }
        }

        return null;
      });
    });
  }
}
