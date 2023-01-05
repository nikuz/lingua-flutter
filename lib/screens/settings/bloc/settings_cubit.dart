import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/models/language.dart';

import './settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SharedPreferences prefs;

  SettingsCubit(this.prefs) : super(SettingsState.initial(prefs));

  void setTranslateFrom(Language language) async {
    await prefs.setString('translateFrom', jsonEncode(language.toJson()));
    emit(state.copyWith(
      translateFrom: language,
    ));
  }

  void setTranslateTo(Language language) async {
    await prefs.setString('translateTo', jsonEncode(language.toJson()));
    emit(state.copyWith(
      translateTo: language,
    ));
  }

  void swapTranslationLanguages(Language from, Language to) async {
    await prefs.setString('translateFrom', jsonEncode(from.toJson()));
    await prefs.setString('translateTo', jsonEncode(to.toJson()));
    emit(state.copyWith(
      translateFrom: from,
      translateTo: to,
    ));
  }

  void setPronunciation(String pronunciation) async {
    await prefs.setString('pronunciation', pronunciation);
    emit(state.copyWith(
      pronunciation: pronunciation,
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

  void setShowLanguageSource(bool value) async {
    await prefs.setBool('showLanguageSource', value);
    emit(state.copyWith(
      showLanguageSource: value,
    ));
  }
}