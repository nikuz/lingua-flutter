import 'package:flutter/material.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/widgets/button/button.dart';
import 'package:lingua_flutter/widgets/bottom_drawer/bottom_drawer.dart';
import 'package:lingua_flutter/styles/styles.dart';

import './language_list.dart';
import './language_selector_size.dart';

class LanguageSelectorItem extends StatelessWidget {
  final String? title;
  final String? selectorTitle;
  final TextStyle? titleStyle;
  final Map<String, String>? languages;
  final Language? language;
  final LanguageSelectorSize size;
  final Function(Language) onChanged;

  const LanguageSelectorItem({
    Key? key,
    this.title,
    this.selectorTitle,
    this.titleStyle,
    this.languages,
    this.language,
    required this.size,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    double buttonHeight = 30;

    if (size == LanguageSelectorSize.large) {
      buttonHeight = 60;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Center(
              child: Text(title!, style: titleStyle),
            ),
          ),

        Button(
          text: language?.value ?? '---',
          size: size == LanguageSelectorSize.large ? ButtonSize.large : ButtonSize.regular,
          height: buttonHeight,
          backgroundColor: theme.colors.cardBackground,
          onPressed: () {
            BottomDrawer(
              context: context,
              builder: (BuildContext drawerContext, ScrollController scrollController) {
                return LanguageList(
                  title: title ?? selectorTitle ?? '',
                  language: language,
                  languages: languages,
                  scrollController: scrollController,
                  onSelected: (Language language) {
                    BottomDrawer.dismiss(context);
                    onChanged(language);
                  },
                );
              },
            ).show();
          },
        ),
      ],
    );
  }
}