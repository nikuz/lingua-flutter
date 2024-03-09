import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/settings_cubit.dart';
import '../../bloc/settings_state.dart';
import '../category/category.dart';
import '../row/row.dart';

class SettingsDarkMode extends StatefulWidget {
  const SettingsDarkMode({super.key});

  @override
  State<SettingsDarkMode> createState() => _SettingsDarkModeState();
}

class _SettingsDarkModeState extends State<SettingsDarkMode> with WidgetsBindingObserver {
  late SettingsCubit _settingsCubit;
  late Brightness _brightness;

  @override
  void initState() {
    super.initState();
    _settingsCubit = context.read<SettingsCubit>();
    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.window.platformBrightness;
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _brightness = WidgetsBinding.instance.window.platformBrightness;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsCategory(
          title: 'Dark mode',
          children: [
            SettingsRow(
              title: 'Dark mode',
              child: Switch(
                value: state.darkMode,
                activeColor: theme.colors.focus,
                onChanged: (value) {
                  _settingsCubit.setDarkMode(value);
                  if (state.autoDarkMode) {
                    _settingsCubit.setAutoDarkMode(false);
                  }
                },
              ),
            ),
            SettingsRow(
              title: 'Auto Dark mode',
              child: Switch(
                value: state.autoDarkMode,
                activeColor: theme.colors.focus,
                onChanged: (value) {
                  _settingsCubit.setAutoDarkMode(value);
                  if (value) {
                    _settingsCubit.setDarkMode(_brightness != Brightness.light);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
