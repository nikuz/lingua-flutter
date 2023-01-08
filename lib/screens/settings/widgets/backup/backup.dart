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
  const SettingsBackup({super.key});

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
                    // outlined: false,
                    loading: state.backupCreateLoading,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () {
                      context.read<SettingsCubit>().createBackup().then((result) {
                        if (result != null) {
                          String message = 'Backup is saved successfully';
                          CustomSnackBarType messageType = CustomSnackBarType.success;

                          if (!result) {
                            message = 'Cannot save a backup';
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
                    onPressed: () {
                      context.read<SettingsCubit>().restoreBackup().then((result) {
                        if (result != null) {
                          String message = 'Words are restored from a backup';
                          CustomSnackBarType messageType = CustomSnackBarType.success;

                          if (!result) {
                            message = 'Cannot restore words from a backup';
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
            )
          ],
        );
      },
    );
  }
}
