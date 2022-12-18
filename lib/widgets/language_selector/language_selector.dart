import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/controllers/languages.dart' as languages_controller;
import 'package:lingua_flutter/widgets/button/button.dart';

import './language_selector_item.dart';
import './language_selector_size.dart';
import './language_selector_emphasis.dart';

export './language_selector_size.dart';
export './language_selector_emphasis.dart';

class LanguageSelector extends StatefulWidget {
  final Language? from;
  final String? fromTitle;
  final Language? to;
  final String? toTitle;
  final LanguageSelectorSize size;
  final LanguageSelectorEmphasis emphasis;
  final Function(Language) onFromChanged;
  final Function(Language, Language) onSwapped;
  final Function(Language) onToChanged;

  const LanguageSelector({
    Key? key,
    this.from,
    this.fromTitle,
    this.to,
    this.toTitle,
    this.size = LanguageSelectorSize.regular,
    this.emphasis = LanguageSelectorEmphasis.languages,
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
    double swapButtonSize = 38;
    EdgeInsets swapButtonMargin = const EdgeInsets.symmetric(horizontal: 5);
    CrossAxisAlignment verticalAlignment = CrossAxisAlignment.center;

    if (widget.size == LanguageSelectorSize.large) {
      swapButtonSize = 50;
      swapButtonMargin = const EdgeInsets.symmetric(horizontal: 5, vertical: 6);
      verticalAlignment = CrossAxisAlignment.end;
    }

    return Container(
      padding: const EdgeInsets.only(
        top: 15,
        right: 10,
        left: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: verticalAlignment,
        children: [
          LanguageSelectorItem(
            title: widget.fromTitle,
            languages: _languages,
            language: widget.from,
            size: widget.size,
            emphasis: widget.emphasis,
            onChanged: (Language language) {
              widget.onFromChanged(language);
            },
          ),
          Button(
            icon: Icons.swap_horiz,
            textColor: theme.colors.primaryPale,
            shape: ButtonShape.circular,
            width: swapButtonSize,
            margin: swapButtonMargin,
            outlined: false,
            onPressed: () {
              if (widget.to != null && widget.from != null) {
                widget.onSwapped(widget.to!, widget.from!);
              }
            },
          ),
          LanguageSelectorItem(
            title: widget.toTitle,
            languages: _languages,
            language: widget.to,
            size: widget.size,
            emphasis: widget.emphasis,
            onChanged: (Language language) {
              widget.onToChanged(language);
            },
          ),
        ],
      ),
    );
  }
}