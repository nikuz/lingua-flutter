import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lingua_flutter/utils/types.dart';

part 'settings_state.g.dart';

@JsonSerializable()
class SettingsState extends Equatable {
  final String translateFrom;
  final String translateTo;
  final bool pronunciationAutoPlay;
  final bool darkMode;
  final bool autoDarkMode;
  final bool backupLoading;
  final bool backupError;
  final int? backupTime;
  final int? backupSize;
  final int? backupPreloadSize;

  const SettingsState({
    required this.translateFrom,
    required this.translateTo,
    required this.pronunciationAutoPlay,
    required this.darkMode,
    required this.autoDarkMode,
    required this.backupLoading,
    required this.backupError,
    this.backupTime,
    this.backupSize,
    this.backupPreloadSize,
  });

  SettingsState copyWith({
    String? translateFrom,
    String? translateTo,
    bool? pronunciationAutoPlay,
    bool? darkMode,
    bool? autoDarkMode,
    bool? backupLoading,
    bool? backupError,
    int? backupTime,
    int? backupSize,
    Wrapped<int?>? backupPreloadSize,
  }) {
    return SettingsState(
      translateFrom: translateFrom ?? this.translateFrom,
      translateTo: translateTo ?? this.translateTo,
      pronunciationAutoPlay: pronunciationAutoPlay ?? this.pronunciationAutoPlay,
      darkMode: darkMode ?? this.darkMode,
      autoDarkMode: autoDarkMode ?? this.autoDarkMode,
      backupLoading: backupLoading ?? this.backupLoading,
      backupError: backupError ?? this.backupError,
      backupTime: backupTime ?? this.backupTime,
      backupSize: backupSize ?? this.backupSize,
      backupPreloadSize: backupPreloadSize != null ? backupPreloadSize.value : this.backupPreloadSize,
    );
  }

  factory SettingsState.initial(SharedPreferences prefs) {
    final String translateFrom = prefs.getString('translateFrom') ?? 'en';
    final String translateTo = prefs.getString('translateTo') ?? 'en';
    final bool pronunciationAutoPlay = prefs.getBool('pronunciationAutoPlay') ?? true;
    final bool darkMode = prefs.getBool('darkMode') ?? false;
    final bool? autoDarkMode = prefs.getBool('autoDarkMode');
    final int? backupTime = prefs.getInt('backupTime');
    final int? backupSize = prefs.getInt('backupSize');

    return SettingsState(
      translateFrom: translateFrom,
      translateTo: translateTo,
      pronunciationAutoPlay: pronunciationAutoPlay,
      darkMode: darkMode,
      autoDarkMode: autoDarkMode ?? true,
      backupLoading: false,
      backupError: false,
      backupTime: backupTime,
      backupSize: backupSize,
    );
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) => _$SettingsStateFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsStateToJson(this);

  @override
  List<Object?> get props => [
    translateFrom,
    translateTo,
    pronunciationAutoPlay,
    darkMode,
    autoDarkMode,
    backupLoading,
    backupError,
    backupTime,
    backupSize,
    backupPreloadSize,
  ];
}