import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lingua_flutter/widgets/language_selector/language_selector.dart';
import 'package:lingua_flutter/screens/router.dart';
import 'package:lingua_flutter/app_config.dart' as config;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        child: DropdownButton<String>(
                          value: state.pronunciation,
                          underline: Container(),
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

                  SettingsCategory(
                    title: 'About',
                    children: [
                      SettingsRow(
                        title: 'Terms & Conditions',
                        type: SettingsRowType.link,
                        onPressed: () {
                          AutoRouter.of(context).pushNamed(Routes.terms);
                        },
                        child: const Icon(
                          Icons.arrow_forward_ios_outlined,
                          size: 20,
                        ),
                      ),
                      SettingsRow(
                        title: 'Privacy Policy',
                        type: SettingsRowType.link,
                        onPressed: () {
                          launchUrl(Uri.parse(config.privacyPolicyUrl));
                        },
                        child: const Icon(
                          Icons.open_in_new_rounded,
                          size: 20,
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
