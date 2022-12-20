import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';
import '../section_wrapper.dart';
import '../speech_part_wrapper.dart';
import './alternative_translations_item.dart';
import './constants.dart';

class TranslationViewAlternativeTranslations extends StatelessWidget {
  const TranslationViewAlternativeTranslations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null) {
          return Container();
        }

        final alternativeTranslations = translation.alternativeTranslations;

        if (alternativeTranslations == null) {
          return Container();
        }

        int itemsAmount = 0;
        for (var item in alternativeTranslations) {
          itemsAmount += item.items.length;
        }

        return TranslationViewSectionWrapper(
          name: 'translations',
          word: state.word,
          itemsAmount: itemsAmount,
          maxItemsToShow: TranslationViewAlternativeTranslationsConstants.minTranslationsToShow * alternativeTranslations.length,
          childBuilder: (bool expanded) => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alternativeTranslations.length,
            itemBuilder: (BuildContext context, int index) {
              final items = alternativeTranslations[index].items;
              return TranslationViewSpeechPartWrapper(
                name: alternativeTranslations[index].speechPart,
                items: items,
                maxItemsToShow: TranslationViewAlternativeTranslationsConstants.minTranslationsToShow,
                expanded: expanded,
                itemBuilder: (BuildContext context, int itemIndex) {
                  return TranslationViewAlternativeTranslationsItem(
                    item: items[itemIndex],
                    isLast: itemIndex == items.length - 1,
                  );
                },
              );
            },
          ),
        );
      }
    );
  }
}
