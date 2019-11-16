import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/bloc.dart';
import './bloc/state.dart';

const SHOW_MIN_DEFINITIONS = 1;

class Definitions extends StatefulWidget {
  @override
  _DefinitionsState createState() => _DefinitionsState();
}

class _DefinitionsState extends State<Definitions> {
  bool expanded = false;
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        if (state is TranslationLoaded) {
          int hiddenItemsAmount = 0;
          if (!expanded) {
            for (int i = 0, l = state.definitions.length; i < l; i++) {
              final List<dynamic> definitions = state.definitions[i][1];
              if (definitions.length > SHOW_MIN_DEFINITIONS) {
                hiddenItemsAmount += definitions.length - SHOW_MIN_DEFINITIONS;
              }
            }
          }

          Widget expandButton = Container(width: 0, height: 0);

          if (expanded || hiddenItemsAmount > 0) {
            expandButton = FlatButton(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
              color: Color.fromRGBO(26, 88, 136, 1),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: Row( // Replace with a Row for horizontal icon + text
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    expanded
                      ? 'Show less definitions'
                      : 'Show more $hiddenItemsAmount definitions',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              },
            );
          }

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(218, 220, 224, 1),
                      width: 1.0,
                      style: BorderStyle.solid
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: new Radius.circular(8.0),
                      bottom: new Radius.circular(expandButton is FlatButton ? 0 : 8.0),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'Definitions of ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(119, 119, 119, 1),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(
                              state.word,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(34, 34, 34, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return DefinitionsCategory(
                            category: state.definitions[index],
                            synonyms: state.definitionsSynonyms,
                            expanded: expanded,
                          );
                        },
                        itemCount: state.definitions.length,
                      ),
                    ],
                  ),
                ),
                expandButton,
              ],
            ),
          );
        }

        return null;
      }
    );
  }
}


class DefinitionsCategory extends StatelessWidget {
  final List<dynamic> category;
  final List<dynamic> synonyms;
  final bool expanded;

  DefinitionsCategory({
    Key key,
    @required this.category,
    @required this.synonyms,
    @required this.expanded
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String categoryName = category[0];
    final List<dynamic> definitions = category[1];
    int definitionsCount = definitions.length;
    List<dynamic> synonymsCategory;

    if (!expanded && definitionsCount > SHOW_MIN_DEFINITIONS) {
      definitionsCount = SHOW_MIN_DEFINITIONS;
    }

    if (synonyms != null && synonyms.isNotEmpty) {
      for (int i = 0, l = synonyms.length; i < l; i++) {
        if (synonyms[i][0] == categoryName) {
          synonymsCategory = synonyms[i][1];
        }
      }
    }

    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              bottom: 5,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '${categoryName[0].toUpperCase()}${categoryName.substring(1)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(66, 133, 224, 1),
                ),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return DefinitionsItem(
                id: index + 1,
                item: definitions[index],
                synonymsCategory: synonymsCategory,
              );
            },
            itemCount: definitionsCount,
          ),
        ],
      ),
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
    final String example = item[2];
    List<dynamic> synonyms;

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
        mainAxisAlignment: MainAxisAlignment.start,
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
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    definition,
                    style: TextStyle(color: Color.fromRGBO(34, 34, 34, 1)),
                  ),
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
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            example,
            style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.54)),
          ),
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
            top: 5,
            right: 10,
            bottom: 5,
            left: 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromRGBO(218, 220, 224, 1),
              width: 1.0,
              style: BorderStyle.solid
            ),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Text(i == l - 1 ? synonyms[i] : '${synonyms[i]}, '),
        )
      );
    }

    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 7,
      children: list,
    );
  }
}
