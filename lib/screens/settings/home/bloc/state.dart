import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsUninitialized extends SettingsState {
  @override
  List<Object> get props => [{
    'pronunciationAutoPlay': true,
    'offlineMode': false,
    'offlineDictionaryUpdateLoading': false,
    'offlineDictionaryUpdateError': false,
    'offlineDictionaryUpdateTime': null,
    'offlineDictionaryUpdateSize': null,
    'offlineDictionaryPreUpdateSize': null,
    'offlineDictionaryClearLoading': false,
    'offlineDictionaryClearConfirmation': false,
  }];
}

class SettingsLoaded extends SettingsState {
  final Map<String, dynamic> settings;

  const SettingsLoaded(this.settings) : assert(settings != null);

  SettingsLoaded copyWith(List<Map<String, dynamic>> props) {
    for (int i = 0, l = props.length; i < l; i++) {
      this.settings..addAll({
        '${props[i]['id']}': props[i]['value'],
      });
    }

    return SettingsLoaded(this.settings);
  }

  @override
  List<Object> get props => settings.entries.toList();
}
