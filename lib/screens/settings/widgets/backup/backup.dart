import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/widgets/button/button.dart';
import 'package:lingua_flutter/widgets/snack_bar/snack_bar.dart';
import 'package:lingua_flutter/utils/time.dart';

import '../../bloc/settings_cubit.dart';
import '../../bloc/settings_state.dart';
import '../category/category.dart';
import '../row/row.dart';

class SettingsBackup extends StatelessWidget {
  const SettingsBackup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        String lastBackupElapsedTime = 'Never';

        if (state.lastBackupAt != null) {
          lastBackupElapsedTime = getElapsedTime(DateTime.fromMillisecondsSinceEpoch(state.lastBackupAt!));
        }

        return SettingsCategory(
          title: 'Backup',
          children: [
            SettingsRow(
              title: 'Keep your words save',
              subtitle: 'Last backup: $lastBackupElapsedTime',
              child: Button(
                text: 'Backup',
                size: ButtonSize.large,
                elevated: true,
                loading: state.backupCreateLoading,
                margin: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  context.read<SettingsCubit>().createBackup().then((result) {
                    if (result != null) {
                      String message = 'Backup is saved successfully';
                      CustomSnackBarType messageType = CustomSnackBarType.success;

                      if (!result) {
                        message = 'Cannot save the backup';
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
              ),
            ),
            SettingsRow(
              title: 'Restore words from backup',
              child: Button(
                text: 'Restore',
                size: ButtonSize.large,
                elevated: true,
                loading: state.backupRestoreLoading,
                margin: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  context.read<SettingsCubit>().restoreBackup().then((result) {
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
              ),
            ),
          ],
        );
      },
    );
  }
}
