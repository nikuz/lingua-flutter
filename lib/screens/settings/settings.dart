import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/widgets/language_selector/language_selector.dart';

import './bloc/settings_cubit.dart';
import './bloc/settings_state.dart';
import './widgets/settings_category.dart';
import './widgets/settings_row.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late SettingsCubit _settingsCubit;

  @override
  void initState() {
    super.initState();
    _settingsCubit = context.read<SettingsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: LanguageSelector(
                      from: state.translateFrom,
                      fromTitle: 'Translate from',
                      to: state.translateTo,
                      toTitle: 'Translate to',
                      size: LanguageSelectorSize.large,
                      onFromChanged: _settingsCubit.setTranslateFrom,
                      onSwapped: _settingsCubit.swapTranslationLanguages,
                      onToChanged: _settingsCubit.setTranslateTo,
                    ),
                  ),
                  SettingsCategory(
                    title: 'Search Results',
                    children: [
                      SettingsRow(
                        title: 'Show translation languages',
                        subtitle: 'Shows source and target languages on translation card',
                        margin: const EdgeInsets.only(top: 7),
                        child: Switch(
                          value: state.showLanguageSource,
                          onChanged: (value) {
                            _settingsCubit.setShowLanguageSource(value);
                          },
                        ),
                      ),
                      SettingsRow(
                        title: 'Pronunciation',
                        subtitle: 'Which pronunciation to play if a single "play" button is available',
                        child: DropdownButton<String>(
                          value: state.pronunciation,
                          onChanged: (String? value) {
                            if (value != null) {
                              _settingsCubit.setPronunciation(value);
                            }
                          },
                          items: ['from', 'to'].map((String item) => (
                              DropdownMenuItem<String>(
                                value: item,
                                child: Text('${item == 'from' ? 'Source' : 'Target'} language'),
                              )
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                  SettingsCategory(
                    // title: 'Dark mode',
                    children: [
                      SettingsRow(
                        title: 'Dark mode',
                        child: Switch(
                          value: state.darkMode,
                          onChanged: state.autoDarkMode ? null : (value) {
                            _settingsCubit.setDarkMode(value);
                          },
                        ),
                      ),
                      SettingsRow(
                        title: 'Auto Dark mode',
                        child: Switch(
                          value: state.autoDarkMode,
                          onChanged: (value) {
                            _settingsCubit.setAutoDarkMode(value);
                            if (value) {
                              _settingsCubit.setDarkMode(false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
