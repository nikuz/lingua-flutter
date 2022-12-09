import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/controllers/languages.dart';
import 'package:lingua_flutter/widgets/bottom_drawer/bottom_drawer.dart';

import '../../bloc/settings_cubit.dart';
import './settings_languages_list.dart';

class SettingsLanguagesSelectorItem extends StatefulWidget {
  final String settingName;
  final String title;
  final String language;

  const SettingsLanguagesSelectorItem({
    Key? key,
    required this.settingName,
    required this.title,
    required this.language,
  }) : super(key: key);

  @override
  State<SettingsLanguagesSelectorItem> createState() => _SettingsLanguagesSelectorItemState();
}

class _SettingsLanguagesSelectorItemState extends State<SettingsLanguagesSelectorItem> {
  List<Language>? _languages;
  String? _languageName;

  @override
  void initState() {
    super.initState();
    _setLanguageName();
  }

  @override
  void didUpdateWidget(covariant SettingsLanguagesSelectorItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      _setLanguageName();
    }
  }

  Future<void> _retrieveLanguages() async {
    if (_languages == null) {
      final storedLanguages = await getLanguages();
      if (storedLanguages != null) {
        _languages = storedLanguages;
      }
    }
  }
  
  void _setLanguageName() async {
    await _retrieveLanguages();
    if (_languages != null) {
      final language = _languages!.firstWhereOrNull((item) => item.id == widget.language);
      setState(() {
        _languageName = language?.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String languageName = widget.language;

    if (_languageName != null) {
      languageName = _languageName!;
      if (languageName.contains('(')) {
        languageName = languageName.split(' ').join('\n');
      }
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(widget.title),
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
                      language: widget.language,
                      languages: _languages,
                      scrollController: scrollController,
                      onSelected: (String language) {
                        final cubit = context.read<SettingsCubit?>();

                        switch (widget.settingName) {
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
                languageName,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}