import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';

class TranslationViewPoweredBy extends StatelessWidget {
  const TranslationViewPoweredBy({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null) {
          return Container();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Powered by Google',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Styles.colors.grey,
                ),
              ),
            )
          ],
        );
      }
    );
  }
}
