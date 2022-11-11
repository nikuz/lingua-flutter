// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsState _$SettingsStateFromJson(Map<String, dynamic> json) =>
    SettingsState(
      pronunciationAutoPlay: json['pronunciationAutoPlay'] as bool,
      darkMode: json['darkMode'] as bool,
      autoDarkMode: json['autoDarkMode'] as bool,
      backupLoading: json['backupLoading'] as bool,
      backupError: json['backupError'] as bool,
      backupTime: json['backupTime'] as int?,
      backupSize: json['backupSize'] as int?,
      backupPreloadSize: json['backupPreloadSize'] as int?,
    );

Map<String, dynamic> _$SettingsStateToJson(SettingsState instance) =>
    <String, dynamic>{
      'pronunciationAutoPlay': instance.pronunciationAutoPlay,
      'darkMode': instance.darkMode,
      'autoDarkMode': instance.autoDarkMode,
      'backupLoading': instance.backupLoading,
      'backupError': instance.backupError,
      'backupTime': instance.backupTime,
      'backupSize': instance.backupSize,
      'backupPreloadSize': instance.backupPreloadSize,
    };
