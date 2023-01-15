import 'package:flutter/material.dart';
import 'package:lingua_flutter/controllers/languages.dart' as languages_controller;
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/styles/styles.dart';

class AutoLanguageDetector extends StatefulWidget {
  final TranslationContainer? translation;
  final EdgeInsets? padding;
  final Color? color;
  final Function(Language)? onPressed;

  const AutoLanguageDetector({
    super.key,
    this.translation,
    this.padding,
    this.color,
    this.onPressed,
  });

  @override
  State<AutoLanguageDetector> createState() => _AutoLanguageDetectorState();
}

class _AutoLanguageDetectorState extends State<AutoLanguageDetector> {
  Map<String, String>? _languages;
  Language? _autoLanguage;

  @override
  void initState() {
    super.initState();
    _retrieveLanguages();
  }

  @override
  void didUpdateWidget(AutoLanguageDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.translation != widget.translation) {
      _setAutoLanguage();
    }
  }

  Future<void> _retrieveLanguages() async {
    if (_languages == null) {
      final storedLanguages = await languages_controller.get();
      if (storedLanguages != null) {
        setState(() {
          _languages = storedLanguages;
        });
        _setAutoLanguage();
      }
    }
  }

  void _setAutoLanguage() async {
    if (_languages == null || widget.translation == null) {
      return;
    }

    for (var id in _languages!.keys) {
      if (id == widget.translation!.autoLanguage) {
        setState(() {
          _autoLanguage = Language(
            id: id,
            value: _languages![id]!,
          );
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = widget.translation;

    if (translation == null
        || translation.autoLanguage == null
        || translation.translateFrom.id == translation.autoLanguage
        || _autoLanguage == null
    ) {
      return Container();
    }

    final isInDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = isInDarkMode ? Styles.colors.orange : Styles.colors.pumpkin;

    return GestureDetector(
      onTap: () {
        if (widget.onPressed is Function && _autoLanguage != null) {
          widget.onPressed!(_autoLanguage!);
        }
      },
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                Icons.auto_awesome,
                color: widget.color ?? color,
              ),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: widget.color ?? color,
                  ),
                  children: [
                    const TextSpan(text: 'Translate from '),
                    TextSpan(
                      text: _autoLanguage!.value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
