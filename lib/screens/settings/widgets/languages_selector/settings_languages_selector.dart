import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/settings_cubit.dart';
import '../../bloc/settings_state.dart';
import './settings_languages_selector_item.dart';

class SettingsLanguagesSelector extends StatelessWidget {

  const SettingsLanguagesSelector({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(
            top: 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SettingsLanguagesSelectorItem(
                title: 'Translate from',
                language: state.translateFrom,
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {

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
              SettingsLanguagesSelectorItem(
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