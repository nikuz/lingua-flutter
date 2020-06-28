import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SettingsGet extends SettingsEvent {}

class SettingsChange extends SettingsEvent {
  final String type;
  final String id;
  final dynamic value;

  SettingsChange({
    @required this.type,
    @required this.id,
    @required this.value,
  });
}

class SettingsDownloadDictionary extends SettingsEvent {}

class SettingsDownloadDictionaryInfo extends SettingsEvent {}

class SettingsDownloadDictionaryHideError extends SettingsEvent {}

class SettingsClearDictionary extends SettingsEvent {}
