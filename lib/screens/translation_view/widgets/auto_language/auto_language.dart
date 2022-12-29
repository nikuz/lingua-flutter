import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/screens/router.gr.dart';
import 'package:lingua_flutter/controllers/languages.dart' as languages_controller;
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';

class TranslationViewAutoLanguage extends StatefulWidget {
  const TranslationViewAutoLanguage({Key? key}) : super(key: key);

  @override
  State<TranslationViewAutoLanguage> createState() => _TranslationViewAutoLanguageState();
}

class _TranslationViewAutoLanguageState extends State<TranslationViewAutoLanguage> {
  Map<String, String>? _languages;
  Language? _autoLanguage;

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
    return BlocListener<TranslationViewCubit, TranslationViewState>(
      listener: (context, state) {
        if (state.translation != null && _autoLanguage == null && _languages != null) {
          Language? autoLanguage;

          for (var id in _languages!.keys) {
            if (id == state.translation!.autoLanguage) {
              autoLanguage = Language(
                id: id,
                value: _languages![id]!,
              );
            }
          }

          if (autoLanguage != null) {
            setState(() {
              _autoLanguage = autoLanguage;
            });
          }
        }
      },
      child: BlocBuilder<TranslationViewCubit, TranslationViewState>(
        builder: (context, state) {
          final translation = state.translation;

          if (translation == null
              || translation.autoLanguage == null
              || translation.translateFrom.id == translation.autoLanguage
              || _autoLanguage == null
          ) {
            return Container();
          }

          return Material(
            type: MaterialType.transparency,
            child: InkWell(
              highlightColor: Styles.colors.white.withOpacity(0.1),
              splashColor: Styles.colors.white.withOpacity(0.2),
              onTap: () {
                context.read<TranslationViewCubit>().reset();
                AutoRouter.of(context).replace(TranslationViewRoute(
                  word: translation.word,
                  translateFrom: _autoLanguage!,
                  // flip target language only if auto language is the same as the target one
                  translateTo: _autoLanguage!.id == translation.translateTo.id
                      ? translation.translateFrom
                      : translation.translateTo,
                ));
              },
              child: Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 4,
                  right: 10,
                  bottom: 6,
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white),
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
        },
      ),
    );
  }
}
