import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/widgets/modal/modal.dart';
import 'package:lingua_flutter/widgets/text_field/text_field.dart';
import 'package:lingua_flutter/widgets/button/button.dart';
import 'package:lingua_flutter/utils/string.dart';

import '../../bloc/translation_view_cubit.dart';

class TranslationViewChangeTranslationModal {
  final BuildContext context;
  final String word;

  const TranslationViewChangeTranslationModal({
    required this.context,
    required this.word,
  });

  void show() {
    Modal(
      context: context,
      child: TranslationViewChangeTranslationContent(
        word: word,
      ),
    ).show();
  }
}

class TranslationViewChangeTranslationContent extends StatefulWidget {
  final String word;

  const TranslationViewChangeTranslationContent({
    super.key,
    required this.word,
  });

  @override
  State<TranslationViewChangeTranslationContent> createState() => _TranslationViewChangeTranslationContentState();
}

class _TranslationViewChangeTranslationContentState extends State<TranslationViewChangeTranslationContent> {
  TranslationViewCubit? _translationViewCubit;
  late String _newTranslation;

  @override
  void initState() {
    super.initState();
    _translationViewCubit = context.read<TranslationViewCubit>();
    _newTranslation = widget.word;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 5,
            right: 5,
            bottom: 10,
            left: 5,
          ),
          child: const Text(
            'Custom translation',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: CustomTextField(
            defaultValue: widget.word,
            autofocus: true,
            textInputAction: TextInputAction.done,
            outlined: true,
            maxLength: 100,
            onChanged: (String value) {
              setState(() {
                _newTranslation = removeQuotesFromString(removeSlashFromString(value)).trim();
              });
            },
            onSubmitted: (String value) {
              if (_newTranslation.isNotEmpty) {
                _translationViewCubit?.setOwnTranslation(_newTranslation);
              }
            },
          ),
        ),

        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                text: 'Cancel',
                size: ButtonSize.large,
                outlined: false,
                width: 100.0,
                height: 40.0,
                margin: const EdgeInsets.only(right: 20),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(false);
                },
              ),

              ButtonBlue(
                text: 'Save',
                size: ButtonSize.large,
                width: 100.0,
                height: 40.0,
                disabled: _newTranslation.isEmpty,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                  _translationViewCubit?.setOwnTranslation(_newTranslation);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
