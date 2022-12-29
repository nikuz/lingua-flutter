import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/screens/router.gr.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';

class TranslationViewAutoSpelling extends StatelessWidget {
  const TranslationViewAutoSpelling({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null || translation.autoSpelling == null) {
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
                word: translation.autoSpelling!,
                translateFrom: translation.translateFrom,
                translateTo: translation.translateTo,
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
                    const TextSpan(text: 'Did you mean "'),
                    TextSpan(
                      text: translation.autoSpelling,
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
    );
  }
}
