import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/widgets/language_selector/language_selector.dart';
import 'package:lingua_flutter/styles/styles.dart';

import './bloc/settings_cubit.dart';
import './bloc/settings_state.dart';
import './widgets/backup/backup.dart';
import './widgets/dark_mode/dark_mode.dart';
import './widgets/search_results/search_results.dart';
import './widgets/about/about.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    final isInDarkMode = theme.brightness == Brightness.dark;
    Color appBarColor = isInDarkMode ? Styles.colors.fakeBlack : Styles.colors.paleGreyDark;

    return Scaffold(
      backgroundColor: appBarColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isInDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isInDarkMode ? Brightness.dark : Brightness.light,
        ),
        foregroundColor: theme.colors.primary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final settingsCubit = context.read<SettingsCubit>();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: LanguageSelector(
                      from: state.translateFrom,
                      fromTitle: 'Translate from',
                      to: state.translateTo,
                      toTitle: 'Translate to',
                      size: LanguageSelectorSize.large,
                      onFromChanged: settingsCubit.setTranslateFrom,
                      onSwapped: settingsCubit.swapTranslationLanguages,
                      onToChanged: settingsCubit.setTranslateTo,
                    ),
                  ),

                  const SettingsBackup(),
                  const SettingsSearchResults(),
                  const SettingsDarkMode(),
                  const SettingsAbout(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
