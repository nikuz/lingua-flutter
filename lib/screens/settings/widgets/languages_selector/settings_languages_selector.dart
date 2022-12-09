import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/settings_cubit.dart';
import '../../bloc/settings_state.dart';
import './settings_languages_selector_item.dart';

class SettingsLanguagesSelector extends StatelessWidget {
  const SettingsLanguagesSelector({Key? key}) : super(key: key);

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
                language: state.translateTo,
              ),
            ],
          ),
        );
      },
    );
  }
}