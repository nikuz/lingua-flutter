import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';
import '../section_wrapper.dart';
import './examples_item.dart';
import './constants.dart';

class TranslationViewExamples extends StatelessWidget {
  const TranslationViewExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null) {
          return Container();
        }

        final examples = translation.examples;

        if (examples == null) {
          return Container();
        }

        return TranslationViewSectionWrapper(
          name: 'examples',
          word: state.word,
          itemsAmount: examples.length,
          maxItemsToShow: TranslationViewExamplesConstants.minTranslationsToShow,
          withBottomMargin: true,
          childBuilder: (bool expanded) => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expanded ? examples.length : TranslationViewExamplesConstants.minTranslationsToShow,
            itemBuilder: (BuildContext context, int index) => ExamplesItem(
              item: examples[index],
            ),
          ),
        );
      }
    );
  }
}