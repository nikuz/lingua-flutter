import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/settings_cubit.dart';
import './bloc/settings_state.dart';
import './widgets/settings_row.dart';
import './widgets/languages_selector/settings_languages_selector.dart';

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
                  const SettingsLanguagesSelector(),
                  SettingsRow(
                    title: 'Autoplay pronunciation',
                    child: Switch(
                      value: state.pronunciationAutoPlay,
                      onChanged: (value) {
                        _settingsCubit.setPronunciationAutoPlay(value);
                      },
                    ),
                  ),
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
            );
          },
        ),
      ),
    );
  }
}
