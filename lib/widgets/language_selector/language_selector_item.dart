import 'package:flutter/material.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/widgets/bottom_drawer/bottom_drawer.dart';

import './language_list.dart';

class LanguageSelectorItem extends StatelessWidget {
  final String title;
  final Map<String, String>? languages;
  final Language language;
  final Function(Language) onChanged;

  const LanguageSelectorItem({
    Key? key,
    required this.title,
    this.languages,
    required this.language,
    required this.onChanged,
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
                    return LanguageList(
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