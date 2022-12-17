import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/widgets/bottom_drawer/bottom_drawer.dart';

import '../../bloc/settings_cubit.dart';
import './settings_languages_list.dart';

class SettingsLanguagesSelectorItem extends StatelessWidget {
  final String settingName;
  final String title;
  final Map<String, String>? languages;
  final Language language;

  const SettingsLanguagesSelectorItem({
    Key? key,
    required this.settingName,
    required this.title,
    this.languages,
    required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(title),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: OutlinedButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(100, 60),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                BottomDrawer(
                  context: context,
                  builder: (BuildContext drawerContext, ScrollController scrollController) {
                    return SettingsLanguagesList(
                      language: language,
                      languages: languages,
                      scrollController: scrollController,
                      onSelected: (Language language) {
                        final cubit = context.read<SettingsCubit?>();

                        switch (settingName) {
                          case 'translateFrom':
                            cubit?.setTranslateFrom(language);
                            break;
                          case 'translateTo':
                            cubit?.setTranslateTo(language);
                            break;
                          default:
                        }

                        BottomDrawer.dismiss(context);
                      },
                    );
                  },
                ).show();
              },
              child: Text(
                language.value,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}