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
      backupTime: (json['backupTime'] as num?)?.toInt(),
      backupSize: (json['backupSize'] as num?)?.toInt(),
      backupPreloadSize: (json['backupPreloadSize'] as num?)?.toInt(),
      showLanguageSource: json['showLanguageSource'] as bool? ?? false,
      backupCreateLoading: json['backupCreateLoading'] as bool? ?? false,
      lastBackupAt: (json['lastBackupAt'] as num?)?.toInt(),
      backupFileIdentifier: json['backupFileIdentifier'] as String?,
      backupRestoreLoading: json['backupRestoreLoading'] as bool? ?? false,
      backupRestoreAt: (json['backupRestoreAt'] as num?)?.toInt(),
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
      'backupCreateLoading': instance.backupCreateLoading,
      'lastBackupAt': instance.lastBackupAt,
      'backupFileIdentifier': instance.backupFileIdentifier,
      'backupRestoreLoading': instance.backupRestoreLoading,
      'backupRestoreAt': instance.backupRestoreAt,
    };
