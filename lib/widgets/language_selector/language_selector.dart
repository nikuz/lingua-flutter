import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/controllers/languages.dart' as languages_controller;

import './language_selector_item.dart';

class LanguageSelector extends StatefulWidget {
  final Language from;
  final Language to;
  final Function(Language) onFromChanged;
  final Function(Language, Language) onSwapped;
  final Function(Language) onToChanged;

  const LanguageSelector({
    Key? key,
    required this.from,
    required this.to,
    required this.onFromChanged,
    required this.onSwapped,
    required this.onToChanged,
  }) : super(key: key);

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
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
          LanguageSelectorItem(
            title: 'Translate from',
            languages: _languages,
            language: widget.from,
            onChanged: (Language language) {
              widget.onFromChanged(language);
            },
          ),
          Container(
            margin: const EdgeInsets.all(5),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  widget.onSwapped(widget.to, widget.from);
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
          LanguageSelectorItem(
            title: 'Translate to',
            languages: _languages,
            language: widget.to,
            onChanged: (Language language) {
              widget.onToChanged(language);
            },
          ),
        ],
      ),
    );
  }
}