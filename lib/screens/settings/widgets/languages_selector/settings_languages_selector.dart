import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/controllers/languages.dart' as languages_controller;

import '../../bloc/settings_cubit.dart';
import '../../bloc/settings_state.dart';
import './settings_languages_selector_item.dart';

class SettingsLanguagesSelector extends StatefulWidget {
  const SettingsLanguagesSelector({Key? key}) : super(key: key);

  @override
  State<SettingsLanguagesSelector> createState() => _SettingsLanguagesSelectorState();
}

class _SettingsLanguagesSelectorState extends State<SettingsLanguagesSelector> {
  Map<String, String>? _languages;

  @override
  void initState() {
    super.initState();
    _retrieveLanguages();
  }

  Future<void> _retrieveLanguages() async {
    if (_languages == null) {
      final storedLanguages = await languages_controller.get();
      if (storedLanguages != null) {
        setState(() {
          _languages = storedLanguages;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.only(
            top: 15,
            right: 10,
            left: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SettingsLanguagesSelectorItem(
                settingName: 'translateFrom',
                title: 'Translate from',
                languages: _languages,
                language: state.translateFrom,
              ),
              Container(
                margin: const EdgeInsets.all(5),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      final cubit = context.read<SettingsCubit?>();
                      cubit?.setTranslateFrom(state.translateTo);
                      cubit?.setTranslateTo(state.translateFrom);
                    },
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.swap_horiz,
                        color: theme.colors.primaryPale,
                      ),
                    ),
                  ),
                ),
              ),
              SettingsLanguagesSelectorItem(
                settingName: 'translateTo',
                title: 'Translate to',
                languages: _languages,
                language: state.translateTo,
              ),
            ],
          ),
        );
      },
    );
  }
}