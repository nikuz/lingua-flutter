import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';
import './section_wrapper.dart';
import './speech_part_wrapper.dart';

const SHOW_MIN_DEFINITIONS = 1;

class TranslationViewDefinitions extends StatelessWidget {
  TranslationViewDefinitions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final definitions = state.definitions;
        if (definitions == null) {
          return Container();
        }

        int itemsAmount = 0;
        for (int i = 0, l = definitions.length; i < l; i++) {
          final List<dynamic>? definitionItems = definitions[i][1];
          if (definitionItems != null) {
            itemsAmount += definitionItems.length;
          }
        }

        return TranslationViewSectionWrapper(
          name: 'definitions',
          word: state.word,
          itemsAmount: itemsAmount,
          maxItemsToShow: SHOW_MIN_DEFINITIONS * definitions.length,
          childBuilder: (bool expanded) => ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: definitions.length,
            itemBuilder: (BuildContext context, int index) => TranslationViewSpeechPartWrapper(
                category: definitions[index],
                maxItemsToShow: SHOW_MIN_DEFINITIONS,
                expanded: expanded,
                itemBuilder: (BuildContext context, int itemIndex) {
                  final category = definitions[index];
                  final String? categoryName = category[0];
                  final List<dynamic> definitionItems = category[1];
                  final List<dynamic>? synonyms = state.definitionsSynonyms;
                  List<dynamic>? synonymsCategory;

                  if (state.version == 1 && synonyms != null && synonyms.isNotEmpty) {
                    for (int i = 0, l = synonyms.length; i < l; i++) {
                      if (synonyms[i][0] == categoryName) {
                        synonymsCategory = synonyms[i][1];
                      }
                    }
                  }

                  return DefinitionsItem(
                    state: state,
                    id: itemIndex + 1,
                    item: definitionItems[itemIndex],
                    synonymsCategory: synonymsCategory,
                  );
                }
            ),
          ),
        );
      }
    );
  }
}


class DefinitionsItem extends StatelessWidget {
  final TranslationViewState state;
  final int id;
  final List<dynamic> item;
  final List<dynamic>? synonymsCategory;

  DefinitionsItem({
    Key? key,
    required this.state,
    required this.id,
    required this.item,
    required this.synonymsCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String definition = item[0];
    String synonymsId = '';
    String? example;
    List<dynamic>? synonyms;

    if (item.length > 1 && item[1] is String) {
      synonymsId = item[1];
    }

    if (state.version == 1 && item.length >= 3) {
      example = item[2];
    } else if (state.version == 2 && item.length > 1) {
      example = item[1];
      if (item.length >= 4) {
        synonyms = item[3];
      }
    }

    if (synonymsCategory != null && synonymsCategory!.isNotEmpty) {
      for (int i = 0, l = synonymsCategory!.length; i < l; i++) {
        if (synonymsCategory![i][1] == synonymsId) {
          synonyms = synonymsCategory![i][0];
        }
      }
    }

    return Container(
      margin: EdgeInsets.only(
        top: 5,
        bottom: 5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 20,
            height: 20,
            margin: EdgeInsets.only(
              top: 3,
              right: 20,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).textTheme.headline2!.color!,
                width: 1,
                style: BorderStyle.solid
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(
              child: Text(
                id.toString(),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  definition,
                  style: TextStyle(fontSize: 17),
                ),
                _getExample(context, example),
                _getSynonymsList(context, synonyms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getExample(BuildContext context, final String? example) {
    if (example != null) {
      return Container(
        margin: EdgeInsets.only(top: 5),
        child: Text(
          example,
          style: TextStyle(
            color: Theme.of(context).textTheme.headline1!.color,
            fontSize: 15,
          ),
        ),
      );
    }

    return Container(width: 0, height: 0);
  }

  Widget _getSynonymsList(BuildContext context, List<dynamic>? synonyms) {
    if (synonyms == null) {
      return Container(width: 0, height: 0);
    }

    List<Widget> list = [];
    for (int i = 0, l = synonyms.length; i < l; i++) {
      list.add(
        Container(
          padding: EdgeInsets.only(
            top: 3,
            right: 8,
            bottom: 5,
            left: 8,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              style: BorderStyle.solid,
              color: Color.fromRGBO(218, 220, 224, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(7)),
          ),
          child: Text(
            synonyms[i],
            style: TextStyle(fontSize: 15),
          ),
        )
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            top: 15,
            bottom: 10,
          ),
          child: Text(
            'Synonyms',
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 15,
            ),
          ),
        ),
        Wrap(
          direction: Axis.horizontal,
          spacing: 7,
          runSpacing: 7,
          children: list,
        )
      ],
    );
  }
}
