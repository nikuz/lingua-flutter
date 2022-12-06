import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';

import './bloc/settings_cubit.dart';
import './bloc/settings_state.dart';
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
            final MyTheme theme = Styles.theme(context);

            String backupTime = '';

            if (state.backupTime != null) {
              final DateTime lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(state.backupTime!);
              backupTime = DateFormat.yMMMd().add_jm().format(lastUpdateDate);
            }

            if (state.backupSize != null) {
              String size = _getParsedFileSize(state.backupSize!);
              backupTime = '$backupTime, $size';
            }

            return Container(
              color: theme.colors.background,
              child: Column(
                children: <Widget>[
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

  String _getParsedFileSize(int fileSize) {
    String sizeSuffix = 'Mb';
    double size = fileSize / 1e+6;
    if (fileSize > 1e+9) {
      sizeSuffix = 'Gb';
      size = fileSize / 1e+9;
    }

    return '${size.toStringAsFixed(2)} $sizeSuffix';
  }
}
