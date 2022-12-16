import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/styles/styles.dart';
import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';

class TranslationViewAutoSpellingFix extends StatelessWidget {
  const TranslationViewAutoSpellingFix({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null) {
          return Container();
        }

        final MyTheme theme = Styles.theme(context);

        if (translation.autoSpellingFix == null) {
          return Container();
        }

        return Container(
          padding: const EdgeInsets.only(
            left: 10,
            top: 4,
            right: 10,
            bottom: 6,
          ),
          color: theme.colors.focus,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white),
              children: [
                const TextSpan(text: 'Did you mean '),
                TextSpan(
                  text: '"${translation.autoSpellingFix}"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
        );
      },
    );
  }
}
