import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsUninitialized extends SettingsState {
  bool get pronunciationAutoPlay => true;
}

class SettingsLoaded extends SettingsState {
  final Map<String, dynamic> settings;

  const SettingsLoaded({
    @required this.settings,
  }) : assert(settings != null);

  SettingsLoaded copyWith({
    String id,
    dynamic value,
  }) {
    return SettingsLoaded(
      settings: {
        '$id': value,
      },
    );
  }

  @override
  List<Object> get props => settings.entries.toList();
}
