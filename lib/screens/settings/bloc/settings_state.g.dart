// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsState _$SettingsStateFromJson(Map<String, dynamic> json) =>
    SettingsState(
      translateFrom:
          Language.fromJson(json['translateFrom'] as Map<String, dynamic>),
      translateTo:
          Language.fromJson(json['translateTo'] as Map<String, dynamic>),
      pronunciation: json['pronunciation'] as String,
      darkMode: json['darkMode'] as bool? ?? false,
      autoDarkMode: json['autoDarkMode'] as bool? ?? true,
      backupLoading: json['backupLoading'] as bool? ?? false,
      backupError: json['backupError'] as bool? ?? false,
      backupTime: json['backupTime'] as int?,
      backupSize: json['backupSize'] as int?,
      backupPreloadSize: json['backupPreloadSize'] as int?,
      showLanguageSource: json['showLanguageSource'] as bool? ?? false,
    );

Map<String, dynamic> _$SettingsStateToJson(SettingsState instance) =>
    <String, dynamic>{
      'translateFrom': instance.translateFrom,
      'translateTo': instance.translateTo,
      'pronunciation': instance.pronunciation,
      'darkMode': instance.darkMode,
      'autoDarkMode': instance.autoDarkMode,
      'backupLoading': instance.backupLoading,
      'backupError': instance.backupError,
      'backupTime': instance.backupTime,
      'backupSize': instance.backupSize,
      'backupPreloadSize': instance.backupPreloadSize,
      'showLanguageSource': instance.showLanguageSource,
    };
