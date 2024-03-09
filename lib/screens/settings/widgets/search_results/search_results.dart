import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/settings_cubit.dart';
import '../../bloc/settings_state.dart';
import '../category/category.dart';
import '../row/row.dart';

class SettingsSearchResults extends StatelessWidget {
  const SettingsSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsCategory(
          title: 'Search Results',
          children: [
            SettingsRow(
              title: 'Show translation languages',
              child: Switch(
                value: state.showLanguageSource,
                activeColor: theme.colors.focus,
                onChanged: (value) {
                  context.read<SettingsCubit>().setShowLanguageSource(value);
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
                    context.read<SettingsCubit>().setPronunciation(value);
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
        );
      },
    );
  }
}
