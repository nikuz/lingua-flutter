import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/bloc.dart';
import './bloc/state.dart';
import './widgets/container.dart';
import './widgets/category.dart';

const SHOW_MIN_DEFINITIONS = 1;

class Definitions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        if (state is TranslationLoaded && state.definitions != null) {

          int itemsLength = 0;
          for (int i = 0, l = state.definitions.length; i < l; i++) {
            final List<dynamic> definitions = state.definitions[i][1];
            itemsLength += definitions.length;
          }

          return TranslationViewContainer(
            title: state.word,
            entity: 'definitions',
            itemsLength: itemsLength,
            maxItemsToShow: SHOW_MIN_DEFINITIONS * state.definitions.length,
            childBuilder: (bool expanded) => ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) => TranslationViewCategory(
                category: state.definitions[index],
                maxItemsToShow: SHOW_MIN_DEFINITIONS,
                expanded: expanded,
                itemBuilder: (BuildContext context, int itemIndex) {
                  final category = state.definitions[index];
                  final String categoryName = category[0];
                  final List<dynamic> definitions = category[1];
                  final List<dynamic> synonyms = state.definitionsSynonyms;
                  List<dynamic> synonymsCategory;

                  if (synonyms != null && synonyms.isNotEmpty) {
                    for (int i = 0, l = synonyms.length; i < l; i++) {
                      if (synonyms[i][0] == categoryName) {
                        synonymsCategory = synonyms[i][1];
                      }
                    }
                  }

                  return DefinitionsItem(
                    id: itemIndex + 1,
                    item: definitions[itemIndex],
                    synonymsCategory: synonymsCategory,
                  );
                }
              ),
              itemCount: state.definitions.length,
            ),
          );
        }

        return Container();
      }
    );
  }
}


class DefinitionsItem extends StatelessWidget {
  final int id;
  final List<dynamic> item;
  final List<dynamic> synonymsCategory;

  DefinitionsItem({
    Key key,
    @required this.id,
    @required this.item,
    @required this.synonymsCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String definition = item[0];
    final String synonymsId = item[1];
    String example;
    List<dynamic> synonyms;

    if (item.length >= 3) {
      example = item[2];
    }

    if (synonymsCategory != null && synonymsCategory.isNotEmpty) {
      for (int i = 0, l = synonymsCategory.length; i < l; i++) {
        if (synonymsCategory[i][1] == synonymsId) {
          synonyms = synonymsCategory[i][0];
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
            margin: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(0, 0, 0, 0.38),
                width: 1.0,
                style: BorderStyle.solid
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Center(
              child: Text(
                id.toString(),
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  definition,
                  style: TextStyle(color: Color.fromRGBO(34, 34, 34, 1)),
                ),
                _getExample(example),
                _getSynonymsList(synonyms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getExample(final String example) {
    if (example != null) {
      return Container(
        margin: EdgeInsets.only(top: 5),
        child: Text(
          example,
          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.54)),
        ),
      );
    }

    return Container(width: 0, height: 0);
  }

  Widget _getSynonymsList(List<dynamic> synonyms) {
    if (synonyms == null) {
      return Container(width: 0, height: 0);
    }

    List<Widget> list = List<Widget>();
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
              color: Color.fromRGBO(218, 220, 224, 1),
              width: 1.0,
              style: BorderStyle.solid
            ),
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
          ),
          child: Text(synonyms[i]),
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
              color: Color.fromRGBO(0, 0, 0, 0.54),
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
