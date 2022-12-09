import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jmespath/jmespath.dart' as jmespath;

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
        final schema = translation?.schema;

        if (translation == null || schema == null) {
          return Container();
        }

        List<dynamic>? definitions = jmespath.search(schema.translation.definitions.value, translation.raw);

        if (definitions == null) {
          return Container();
        }

        int itemsAmount = 0;

        for (var speechPart in definitions) {
          List<dynamic>? items = jmespath.search(schema.translation.definitions.items.value, speechPart);
          if (items != null) {
            itemsAmount += items.length;
          }
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
              List<dynamic>? items = jmespath.search(schema.translation.definitions.items.value, definitions[index]);
              return TranslationViewSpeechPartWrapper(
                name: jmespath.search(schema.translation.definitions.speechPart.value, definitions[index]),
                items: items,
                maxItemsToShow: TranslationViewDefinitionsConstants.minTranslationsToShow,
                expanded: expanded,
                itemBuilder: (BuildContext context, int itemIndex) {
                  if (items == null) {
                    return Container();
                  }

                  return DefinitionsItem(
                    index: itemIndex + 1,
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