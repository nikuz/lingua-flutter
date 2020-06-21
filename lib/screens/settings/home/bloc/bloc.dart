import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      yield SettingsLoaded(
        settings: {
          'pronunciationAutoPlay': pronunciationAutoPlay,
        },
      );
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

          yield currentState.copyWith(
            id: event.id,
            value: event.value,
          );
        }
    }
  }

//  Future<Translations> _fetchTranslationsList(int from, int to, {String searchText}) async {
//    final String url = searchText == null ? '/translations' : '/translate/search';
//    final Map<String, dynamic> response = await apiGet(
//        client: httpClient,
//        url: url,
//        params: {
//          'q': searchText,
//          'from': '$from',
//          'to': '$to',
//        }
//    );
//
//    return Translations(
//      from: response['from'],
//      to: response['to'],
//      totalAmount: response['totalAmount'],
//      translations: response['translations'].map<TranslationsItem>((rawTranslation) => (
//          TranslationsItem(
//            id: rawTranslation['id'],
//            word: rawTranslation['word'],
//            translation: rawTranslation['translation'],
//            pronunciation: rawTranslation['pronunciation'],
//            image: rawTranslation['image'],
//            createdAt: rawTranslation['created_at'],
//            updatedAt: rawTranslation['updated_at'],
//          )
//      )).toList(),
//    );
//  }
//
//  Future<bool> _removeTranslationsItem(int id) async {
//    final Map<String, dynamic> response = await apiDelete(
//        client: httpClient,
//        url: '/translate',
//        params: {
//          'id': '$id',
//        }
//    );
//
//    if (response['success'] == true) {
//      return true;
//    } else {
//      return false;
//    }
//  }
}
