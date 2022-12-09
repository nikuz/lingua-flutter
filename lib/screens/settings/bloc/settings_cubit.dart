import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SharedPreferences prefs;

  SettingsCubit(this.prefs) : super(SettingsState.initial(prefs));

  void setTranslateFrom(String language) async {
    await prefs.setString('translateFrom', language);
    emit(state.copyWith(
      translateFrom: language,
    ));
  }

  void setTranslateTo(String language) async {
    await prefs.setString('translateTo', language);
    emit(state.copyWith(
      translateTo: language,
    ));
  }

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
}