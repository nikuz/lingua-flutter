import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/prompts.dart';

import './bloc/settings_cubit.dart';
import './bloc/settings_state.dart';
import './widgets/settings_row.dart';
import './widgets/settings_button.dart';

class Settings extends StatefulWidget {
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
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) async {
        if (state.backupError) {
          await prompt(
            context: context,
            title: 'Error',
            text: 'Some error occurred during backup download. Please try again later.',
            acceptCallback: () => _settingsCubit.clearBackupError(),
            closeCallback: () => _settingsCubit.clearBackupError(),
          );
        }
        if (state.backupPreloadSize != null) {
          String size = _getParsedFileSize(state.backupPreloadSize!);
          await prompt(
            context: context,
            title: 'Backup size',
            text: 'Backup file size is $size. Download?',
            withCancel: true,
            acceptCallback: () {
              _settingsCubit.downloadBackup();
            },
            closeCallback: () {
              _settingsCubit.clearBackupPreloadSize();
            },
          );
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final MyTheme theme = Styles.theme(context);

          String backupTime = '';

          if (state.backupTime != null) {
            final DateTime lastUpdateDate = new DateTime.fromMillisecondsSinceEpoch(state.backupTime!);
            backupTime = new DateFormat.yMMMd().add_jm().format(lastUpdateDate);
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
                  title: 'Respect system Dark mode',
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
                SettingsRow(
                  title: 'Backup',
                  subtitle: backupTime != '' ? backupTime : null,
                  child: SettingsButton(
                    icon: Icons.file_download,
                    loading: state.backupLoading,
                    onPressed: () {
                      _settingsCubit.getBackupInfo();
                      // _settingsBloc.add(SettingsDownloadDictionaryInfo());
                    },
                  ),
                ),
              ],
            ),
          );
        },
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
