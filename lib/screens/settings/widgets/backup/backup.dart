import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/widgets/button/button.dart';
import 'package:lingua_flutter/widgets/snack_bar/snack_bar.dart';
import 'package:lingua_flutter/widgets/prompt/prompt.dart';
import 'package:lingua_flutter/utils/time.dart';
import 'package:lingua_flutter/controllers/backup/backup.dart' as backup_controller;
import 'package:lingua_flutter/controllers/dictionary/dictionary.dart' as dictionary_controller;
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/settings_cubit.dart';
import '../../bloc/settings_state.dart';
import '../category/category.dart';
import '../row/row.dart';

class SettingsBackup extends StatefulWidget {
  const SettingsBackup({super.key});

  @override
  State<SettingsBackup> createState() => _SettingsBackupState();
}

class _SettingsBackupState extends State<SettingsBackup> {
  void _backupHandler() {
    context.read<SettingsCubit>().createBackup().then((result) {
      if (result != null) {
        String message = 'Backup is saved successfully';
        CustomSnackBarType messageType = CustomSnackBarType.success;

        if (!result) {
          message = 'Unable to save a backup';
          messageType = CustomSnackBarType.error;
        }

        CustomSnackBar(
          context: context,
          message: message,
          type: messageType,
        ).show();
      }
    });
  }

  void _restoreHandler(backup_controller.BackupInfo backupInfo) async {
    final settingsState = context.read<SettingsCubit>();
    settingsState.setRestoreBackupLoading(true);

    if (backupInfo.filePath != null) {
      settingsState.restoreBackup(backupInfo.filePath!).then((result) {
        settingsState.setRestoreBackupLoading(false);
        if (result != null) {
          String message = 'Words are restored from the backup';
          CustomSnackBarType messageType = CustomSnackBarType.success;

          if (!result) {
            message = 'Cannot restore words from the backup';
            messageType = CustomSnackBarType.error;
          }

          CustomSnackBar(
            context: context,
            message: message,
            type: messageType,
          ).show();
        }
      });
    }
  }

  void _prepareRestore(String? backupFileIdentifier) async {
    final settingsState = context.read<SettingsCubit>();
    final MyTheme theme = Styles.theme(context);
    backup_controller.BackupInfo? backupInfo;

    settingsState.setRestoreBackupLoading(true);

    try {
      backupInfo = await backup_controller.getBackupFileInfo(backupFileIdentifier);
    } catch (err) {
      CustomSnackBar(
        context: context,
        message: err.toString(),
        type: CustomSnackBarType.error,
      ).show();
    }

    settingsState.setRestoreBackupLoading(false);

    if (backupInfo != null && backupInfo.filePath != null) {
      final amountOfSavedWords = await dictionary_controller.getListLength();

      if (amountOfSavedWords > 0) {
        Prompt(
          context: context,
          child: Container(
            margin: const EdgeInsets.only(
              top: 5,
              right: 5,
              bottom: 10,
              left: 5,
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  color: theme.colors.primary,
                ),
                children: [
                  const TextSpan(text: 'Your current list of '),
                  TextSpan(
                    text: '$amountOfSavedWords',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' word${amountOfSavedWords > 1 ? 's' : ''} will be replaced with '),
                  TextSpan(
                    text: '${backupInfo.wordsAmount}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' word${backupInfo.wordsAmount > 1 ? 's' : ''} from the backup. Is that okay?'),
                ],
              ),
            ),
          ),
          acceptCallback: () {
            _restoreHandler(backupInfo!);
          },
          cancelCallback: () async {
            await backup_controller.removeTemporaryBackupFile(backupInfo!.filePath!);
          },
        ).show();
      } else {
        if (mounted) {
          _restoreHandler(backupInfo);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        String lastBackupElapsedTime = 'Never';

        if (state.lastBackupAt != null) {
          lastBackupElapsedTime = getElapsedTime(DateTime.fromMillisecondsSinceEpoch(state.lastBackupAt!));
        }

        return Column(
          children: [
            SettingsCategory(
              title: 'Backup',
              children: [
                SettingsRow(
                  title: 'Backup your words',
                  subtitle: 'Last backup: $lastBackupElapsedTime',
                  child: Button(
                    icon: Icons.backup,
                    iconSize: 30,
                    shape: ButtonShape.oval,
                    loading: state.backupCreateLoading,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () => _backupHandler(),
                  ),
                ),
              ],
            ),

            SettingsCategory(
              title: 'Restore',
              children: [
                SettingsRow(
                  title: 'Restore words from a backup',
                  child: Button(
                    icon: Icons.settings_backup_restore,
                    iconSize: 30,
                    shape: ButtonShape.oval,
                    loading: state.backupRestoreLoading,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () => _prepareRestore(state.backupFileIdentifier),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
