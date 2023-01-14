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

    final MyTheme theme = Styles.theme(context);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        highlightColor: Styles.colors.white.withOpacity(0.1),
        splashColor: Styles.colors.white.withOpacity(0.2),
        onTap: () {
          if (widget.onPressed is Function && _autoLanguage != null) {
            widget.onPressed!(_autoLanguage!);
          }
        },
        child: Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: widget.color ?? theme.colors.focus,
                decoration: TextDecoration.underline,
              ),
              children: [
                const TextSpan(text: 'Translate from "'),
                TextSpan(
                  text: _autoLanguage!.value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '"?'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
