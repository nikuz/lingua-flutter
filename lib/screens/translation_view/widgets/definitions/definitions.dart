import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';
import '../section_wrapper.dart';
import '../speech_part_wrapper.dart';
import './definitions_item.dart';
import './constants.dart';

class TranslationViewDefinitions extends StatelessWidget {
  const TranslationViewDefinitions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null) {
          return Container();
        }

        final definitions = translation.definitions;

        if (definitions == null) {
          return Container();
        }

        int itemsAmount = 0;
        for (var item in definitions) {
          itemsAmount += item.items.length;
        }

        return TranslationViewSectionWrapper(
          name: 'definitions',
          word: state.word,
          itemsAmount: itemsAmount,
          maxItemsToShow: TranslationViewDefinitionsConstants.minTranslationsToShow * definitions.length,
          childBuilder: (bool expanded) => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: definitions.length,
            itemBuilder: (BuildContext context, int index) {
              final items = definitions[index].items;
              return TranslationViewSpeechPartWrapper(
                name: definitions[index].speechPart,
                items: items,
                maxItemsToShow: TranslationViewDefinitionsConstants.minTranslationsToShow,
                expanded: expanded,
                itemBuilder: (BuildContext context, int itemIndex) {
                  return DefinitionsItem(
                    index: itemIndex + 1,
                    item: items[itemIndex],
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