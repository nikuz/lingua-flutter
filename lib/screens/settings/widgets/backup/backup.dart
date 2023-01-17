import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/widgets/button/button.dart';
import 'package:lingua_flutter/widgets/snack_bar/snack_bar.dart';
import 'package:lingua_flutter/widgets/prompt/prompt.dart';
import 'package:lingua_flutter/utils/time.dart';
import 'package:lingua_flutter/controllers/backup/backup.dart' as backup_controller;

import '../../bloc/settings_cubit.dart';
import '../../bloc/settings_state.dart';
import '../category/category.dart';
import '../row/row.dart';

class SettingsBackup extends StatelessWidget {
  const SettingsBackup({super.key});

  void _backupHandler(BuildContext context) {
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

  void _restoreHandler(BuildContext context, String? backupFileIdentifier) async {
    final settingsState = context.read<SettingsCubit>();
    String? backupFilePath;

    settingsState.setRestoreBackupLoading(true);

    try {
      backupFilePath = await backup_controller.getBackupFilePath(backupFileIdentifier);
    } catch (err) {
      settingsState.setRestoreBackupLoading(false);
      CustomSnackBar(
        context: context,
        message: err.toString(),
        type: CustomSnackBarType.error,
      ).show();
      return;
    }

    if (backupFilePath != null) {
      Prompt(
        context: context,
        title: 'Your current list of words will be replaced with the words from the backup. Is that okay?',
        acceptCallback: () {
          settingsState.restoreBackup(backupFilePath!).then((result) {
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
        },
        cancelCallback: () async {
          settingsState.setRestoreBackupLoading(false);
          await backup_controller.removeTemporaryBackupFile(backupFilePath!);
        }
      ).show();
    } else {
      settingsState.setRestoreBackupLoading(false);
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
                    onPressed: () => _backupHandler(context),
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
                    // outlined: false,
                    loading: state.backupRestoreLoading,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () => _restoreHandler(context, state.backupFileIdentifier),
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
