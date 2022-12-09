import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jmespath/jmespath.dart' as jmespath;

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
        final schema = translation?.schema;

        if (translation == null || schema == null) {
          return Container();
        }

        List<dynamic>? alternativeTranslations = jmespath.search(
            schema.translation.alternativeTranslations.value,
            translation.raw
        );

        if (alternativeTranslations == null) {
          return Container();
        }

        int itemsAmount = 0;

        for (var speechPart in alternativeTranslations) {
          List<dynamic>? items = jmespath.search(schema.translation.alternativeTranslations.items.value, speechPart);
          if (items != null) {
            itemsAmount += items.length;
          }
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
              List<dynamic>? items = jmespath.search(
                  schema.translation.alternativeTranslations.items.value,
                  alternativeTranslations[index]
              );
              return TranslationViewSpeechPartWrapper(
                name: jmespath.search(schema.translation.alternativeTranslations.speechPart.value, alternativeTranslations[index]),
                items: items,
                maxItemsToShow: TranslationViewAlternativeTranslationsConstants.minTranslationsToShow,
                expanded: expanded,
                itemBuilder: (BuildContext context, int itemIndex) {
                  if (items == null) {
                    return Container();
                  }

                  return TranslationViewAlternativeTranslationsItem(
                    data: items[itemIndex],
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
