import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';

class TranslationViewNoAdditionalData extends StatelessWidget {
  const TranslationViewNoAdditionalData({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null
            || translation.alternativeTranslations != null
            || translation.definitions != null
            || translation.examples != null
        ) {
          return Container();
        }

        final MyTheme theme = Styles.theme(context);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                color: theme.colors.grey,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Translation "'),
                TextSpan(
                  text: translation.word,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '" from "'),
                TextSpan(
                  text: translation.translateFrom.value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '" to "'),
                TextSpan(
                  text: translation.translateTo.value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '" has no alternative translations or examples.'),
              ],
            ),
          ),
        );
      },
    );
  }
}
