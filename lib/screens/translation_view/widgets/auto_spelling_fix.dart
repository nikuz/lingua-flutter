import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jmespath/jmespath.dart' as jmespath;

import 'package:lingua_flutter/styles/styles.dart';
import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';

class TranslationViewAutoSpellingFix extends StatelessWidget {
  TranslationViewAutoSpellingFix({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;
        final schema = translation?.schema;

        if (translation == null || schema == null) {
          return Container();
        }

        final MyTheme theme = Styles.theme(context);
        String? autoSpellingFix = jmespath.search(schema.translation.autoSpellingFix.value, translation.raw);

        if (autoSpellingFix == null) {
          return Container();
        }

        return Container(
          padding: EdgeInsets.only(
            left: 10,
            top: 4,
            right: 10,
            bottom: 6,
          ),
          color: theme.colors.focus,
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white),
              children: [
                TextSpan(text: 'Did you mean '),
                TextSpan(
                  text: '"$autoSpellingFix"',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '?'),
              ],
            ),
          ),
        );
      },
    );
  }
}
