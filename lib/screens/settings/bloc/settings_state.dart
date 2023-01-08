import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/utils/types.dart';

part 'settings_state.g.dart';

@JsonSerializable()
class SettingsState extends Equatable {
  final Language translateFrom;
  final Language translateTo;
  final String pronunciation;
  final bool darkMode;
  final bool autoDarkMode;
  final bool backupLoading;
  final bool backupError;
  final int? backupTime;
  final int? backupSize;
  final int? backupPreloadSize;
  final bool showLanguageSource;
  final bool backupCreateLoading;
  final int? lastBackupAt;
  final String? backupFileIdentifier;
  final bool backupRestoreLoading;
  final int? backupRestoreAt;

  const SettingsState({
    required this.translateFrom,
    required this.translateTo,
    required this.pronunciation,
    this.darkMode = false,
    this.autoDarkMode = true,
    this.backupLoading = false,
    this.backupError = false,
    this.backupTime,
    this.backupSize,
    this.backupPreloadSize,
    this.showLanguageSource = false,
    this.backupCreateLoading = false,
    this.lastBackupAt,
    this.backupFileIdentifier,
    this.backupRestoreLoading = false,
    this.backupRestoreAt,
  });

  SettingsState copyWith({
    Language? translateFrom,
    Language? translateTo,
    String? pronunciation,
    bool? darkMode,
    bool? autoDarkMode,
    bool? backupLoading,
    bool? backupError,
    int? backupTime,
    int? backupSize,
    Wrapped<int?>? backupPreloadSize,
    bool? showLanguageSource,
    bool? backupCreateLoading,
    int? lastBackupAt,
    String? backupFileIdentifier,
    bool? backupRestoreLoading,
    int? backupRestoreAt,
  }) {
    return SettingsState(
      translateFrom: translateFrom ?? this.translateFrom,
      translateTo: translateTo ?? this.translateTo,
      pronunciation: pronunciation ?? this.pronunciation,
      darkMode: darkMode ?? this.darkMode,
      autoDarkMode: autoDarkMode ?? this.autoDarkMode,
      backupLoading: backupLoading ?? this.backupLoading,
      backupError: backupError ?? this.backupError,
      backupTime: backupTime ?? this.backupTime,
      backupSize: backupSize ?? this.backupSize,
      backupPreloadSize: backupPreloadSize != null ? backupPreloadSize.value : this.backupPreloadSize,
      showLanguageSource: showLanguageSource ?? this.showLanguageSource,
      backupCreateLoading: backupCreateLoading ?? this.backupCreateLoading,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      backupFileIdentifier: backupFileIdentifier ?? this.backupFileIdentifier,
      backupRestoreLoading: backupRestoreLoading ?? this.backupRestoreLoading,
      backupRestoreAt: backupRestoreAt ?? this.backupRestoreAt,
    );
  }

  factory SettingsState.initial(SharedPreferences prefs) {
    final String? translateFromString = prefs.getString('translateFrom');
    Language translateFrom = const Language(id: 'en', value: 'English');

    if (translateFromString != null) {
      try {
        translateFrom = Language.fromJson(jsonDecode(translateFromString));
      } catch (e) {
        //
      }
    }

    final String? translateToString = prefs.getString('translateTo');
    Language translateTo = const Language(id: 'en', value: 'English');

    if (translateToString != null) {
      try {
        translateTo = Language.fromJson(jsonDecode(translateToString));
      } catch (e) {
        //
      }
    }

    final String? pronunciation = prefs.getString('pronunciation');
    final bool? darkMode = prefs.getBool('darkMode');
    final bool? autoDarkMode = prefs.getBool('autoDarkMode');
    final int? backupTime = prefs.getInt('backupTime');
    final int? backupSize = prefs.getInt('backupSize');
    final bool? showLanguageSource = prefs.getBool('showLanguageSource');
    final int? lastBackupAt = prefs.getInt('lastBackupAt');
    final String? backupFileIdentifier = prefs.getString('backupFileIdentifier');

    return SettingsState(
      translateFrom: translateFrom,
      translateTo: translateTo,
      pronunciation: pronunciation ?? 'from',
      darkMode: darkMode ?? false,
      autoDarkMode: autoDarkMode ?? true,
      backupTime: backupTime,
      backupSize: backupSize,
      showLanguageSource: showLanguageSource ?? false,
      lastBackupAt: lastBackupAt,
      backupFileIdentifier: backupFileIdentifier,
    );
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) => _$SettingsStateFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsStateToJson(this);

  @override
  List<Object?> get props => [
    translateFrom,
    translateTo,
    pronunciation,
    darkMode,
    autoDarkMode,
    backupLoading,
    backupError,
    backupTime,
    backupSize,
    backupPreloadSize,
    showLanguageSource,
    backupCreateLoading,
    lastBackupAt,
    backupRestoreLoading,
    backupRestoreAt,
    backupFileIdentifier,
  ];
}