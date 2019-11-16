import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/bloc.dart';
import './bloc/state.dart';

const SHOW_MIN_TRANSLATIONS = 5;

class OtherTranslations extends StatefulWidget {
  @override
  _OtherTranslationsState createState() => _OtherTranslationsState();
}

class _OtherTranslationsState extends State<OtherTranslations> {
  bool expanded = false;
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        if (state is TranslationLoaded) {
          int hiddenItemsAmount = 0;
          if (!expanded) {
            for (int i = 0, l = state.otherTranslations.length; i < l; i++) {
              final List<dynamic> translations = state.otherTranslations[i][2];
              if (translations.length > SHOW_MIN_TRANSLATIONS) {
                hiddenItemsAmount += translations.length - SHOW_MIN_TRANSLATIONS;
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
                      ? 'Show less translations'
                      : 'Show more $hiddenItemsAmount translations',
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
            margin: EdgeInsets.all(10),
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
                            'Translations of ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(119, 119, 119, 1),
                            ),
                          ),
                          Text(
                            state.word,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(34, 34, 34, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return OtherTranslationsCategory(
                            category: state.otherTranslations[index],
                            expanded: expanded,
                          );
                        },
                        itemCount: state.otherTranslations.length,
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


class OtherTranslationsCategory extends StatelessWidget {
  final List<dynamic> category;
  final bool expanded;

  OtherTranslationsCategory({
    Key key,
    @required this.category,
    @required this.expanded
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String categoryName = category[0];
    final List<dynamic> translations = category[2];
    int translationsCount = translations.length;

    if (!expanded && translationsCount > SHOW_MIN_TRANSLATIONS) {
      translationsCount = SHOW_MIN_TRANSLATIONS;
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
              return OtherTranslationsItem(
                item: translations[index]
              );
            },
            itemCount: translationsCount,
          ),
        ],
      ),
    );
  }
}

class OtherTranslationsItem extends StatelessWidget {
  final List<dynamic> item;

  OtherTranslationsItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String word = item[0];
    List<dynamic> synonyms;
    double frequency;

    if (item[1] != null) {
      synonyms = item[1];
    }
    if (item.length >= 4) {
      frequency = item[3];
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
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(
              word,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.37,
            child: _getSynonymsList(synonyms),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 8,
              left: 10,
            ),
            child: Row(
              children: <Widget>[
                _getFrequencyBarItem(true),
                _getFrequencyBarItem(frequency != null && frequency > 0.001),
                _getFrequencyBarItem(frequency != null && frequency > 0.1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSynonymsList(List<dynamic> synonyms) {
    List<Widget> list = List<Widget>();
    for (int i = 0, l = synonyms.length; i < l; i++) {
      list.add(Text(i == l - 1 ? synonyms[i] : '${synonyms[i]}, '));
    }

    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 7,
      children: list,
    );
  }

  Widget _getFrequencyBarItem(bool active) {
    return Container(
      width: 10,
      height: 3,
      margin: EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: active
          ? Color.fromRGBO(66, 133, 224, 1)
          : Color.fromRGBO(218, 220, 224, 1),
        borderRadius: BorderRadius.all(Radius.circular(1.0)),
      ),
    );
  }
}
