import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';
import '../section_wrapper.dart';
import '../speech_part_wrapper.dart';
import './alternative_translations_item.dart';
import './constants.dart';

const MIN_TRANSLATIONS_TO_SHOW = TranslationViewAlternativeTranslationsConstants.minTranslationsToShow;

class TranslationViewAlternativeTranslations extends StatelessWidget {
  TranslationViewAlternativeTranslations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final alternativeTranslations = state.alternativeTranslations;
        if (alternativeTranslations == null) {
          return Container();
        }

        int itemsAmount = 0;
        int categoriesAmount = alternativeTranslations.length;

        for (int i = 0, l = categoriesAmount; i < l; i++) {
          List<dynamic>? translations;
          if (state.version == 1) {
            translations = alternativeTranslations[i][2];
          } else if (state.version == 2) {
            translations = alternativeTranslations[i][1];
          }
          if (translations != null) {
            itemsAmount += translations.length;
          }
        }

        return TranslationViewSectionWrapper(
          name: 'translations',
          word: state.word,
          itemsAmount: itemsAmount,
          maxItemsToShow: MIN_TRANSLATIONS_TO_SHOW * categoriesAmount,
          childBuilder: (bool expanded) => ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: categoriesAmount,
            itemBuilder: (BuildContext context, int index) => TranslationViewSpeechPartWrapper(
                category: alternativeTranslations[index],
                maxItemsToShow: MIN_TRANSLATIONS_TO_SHOW,
                expanded: expanded,
                itemBuilder: (BuildContext context, int itemIndex) {
                  final category = alternativeTranslations[index];
                  List<dynamic>? translations;

                  if (state.version == 1) {
                    translations = category[2];
                  } else if (state.version == 2) {
                    translations = category[1];
                  }

                  return TranslationViewAlternativeTranslationsItem(
                    state: state,
                    item: translations![itemIndex],
                  );
                }
            ),
          ),
        );
      }
    );
  }
}
