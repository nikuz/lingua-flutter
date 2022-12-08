import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/controllers/languages.dart';
// import 'package:lingua_flutter/widgets/modal/modal.dart';

class SettingsLanguagesSelectorItem extends StatefulWidget {
  final String title;
  final String language;

  const SettingsLanguagesSelectorItem({
    Key? key,
    required this.title,
    required this.language,
  }) : super(key: key);

  @override
  State<SettingsLanguagesSelectorItem> createState() => _SettingsLanguagesSelectorItemState();
}

class _SettingsLanguagesSelectorItemState extends State<SettingsLanguagesSelectorItem> {
  String? _languageName;
  
  @override
  void initState() {
    super.initState();
    _setLanguageName();
  }
  
  void _setLanguageName() async {
    final languages = await getLanguages();
    if (languages != null) {
      final language = languages.firstWhereOrNull((item) => item.id == widget.language);
      if (language != null) {
        setState(() {
          _languageName = language.value;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return Expanded(
      child: Column(
        children: [
          Center(
            child: Text(widget.title),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Styles.colors.white,
                backgroundColor: theme.colors.focusBackground,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: const TextStyle(fontSize: 17),
              ),
              onPressed: () {
                // Modal(
                //   context: context,
                //   children: [
                //     Text('Select a languaage'),
                //   ]
                // ).show();
              },
              child: Text(_languageName ?? widget.language),
            ),
          ),
        ],
      ),
    );
  }
}