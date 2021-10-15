import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/utils/sizes.dart';

import 'bloc/bloc.dart';
import 'bloc/state.dart';
import 'widgets/container.dart';
import 'widgets/category.dart';

const SHOW_MIN_DEFINITIONS = 1;

class Definitions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        if (state is TranslationLoaded && state.definitions != null) {

          int itemsAmount = 0;
          for (int i = 0, l = state.definitions.length; i < l; i++) {
            final List<dynamic> definitions = state.definitions[i][1];
            itemsAmount += definitions.length;
          }

          return TranslationViewContainer(
            title: state.word,
            entity: 'definitions',
            itemsAmount: itemsAmount,
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
  final TranslationLoaded state;
  final int id;
  final List<dynamic> item;
  final List<dynamic> synonymsCategory;

  DefinitionsItem({
    Key key,
    @required this.state,
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

    if (state.version == 1 && item.length >= 3) {
      example = item[2];
    } else if (state.version == 2) {
      example = item[1];
      if (item.length >= 4) {
        synonyms = item[3];
      }
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
        top: SizeUtil.vmax(5),
        bottom: SizeUtil.vmax(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: SizeUtil.vmax(20),
            height: SizeUtil.vmax(20),
            margin: EdgeInsets.only(
              top: SizeUtil.vmax(3),
              right: SizeUtil.vmax(20),
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).textTheme.headline2.color,
                width: SizeUtil.vmax(1),
                style: BorderStyle.solid
              ),
              borderRadius: BorderRadius.all(Radius.circular(SizeUtil.vmax(20))),
            ),
            child: Center(
              child: Text(
                id.toString(),
                style: TextStyle(
                  fontSize: SizeUtil.vmax(12),
                ),
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
                  style: TextStyle(
                    fontSize: SizeUtil.vmax(17),
                  ),
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

  Widget _getExample(BuildContext context, final String example) {
    if (example != null) {
      return Container(
        margin: EdgeInsets.only(top: SizeUtil.vmax(5)),
        child: Text(
          example,
          style: TextStyle(
            color: Theme.of(context).textTheme.headline1.color,
            fontSize: SizeUtil.vmax(15),
          ),
        ),
      );
    }

    return Container(width: 0, height: 0);
  }

  Widget _getSynonymsList(BuildContext context, List<dynamic> synonyms) {
    if (synonyms == null) {
      return Container(width: 0, height: 0);
    }

    List<Widget> list = List<Widget>();
    for (int i = 0, l = synonyms.length; i < l; i++) {
      list.add(
        Container(
          padding: EdgeInsets.only(
            top: SizeUtil.vmax(3),
            right: SizeUtil.vmax(8),
            bottom: SizeUtil.vmax(5),
            left: SizeUtil.vmax(8),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromRGBO(218, 220, 224, 1),
              width: SizeUtil.vmax(1),
              style: BorderStyle.solid
            ),
            borderRadius: BorderRadius.all(Radius.circular(SizeUtil.vmax(7))),
          ),
          child: Text(
            synonyms[i],
            style: TextStyle(
              fontSize: SizeUtil.vmax(15),
            ),
          ),
        )
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            top: SizeUtil.vmax(15),
            bottom: SizeUtil.vmax(10),
          ),
          child: Text(
            'Synonyms',
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: SizeUtil.vmax(15),
            ),
          ),
        ),
        Wrap(
          direction: Axis.horizontal,
          spacing: SizeUtil.vmax(7),
          runSpacing: SizeUtil.vmax(7),
          children: list,
        )
      ],
    );
  }
}
