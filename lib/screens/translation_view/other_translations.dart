import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/bloc.dart';
import './bloc/state.dart';
import './widgets/container.dart';

const SHOW_MIN_TRANSLATIONS = 5;

class OtherTranslations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        if (state is TranslationLoaded && state.otherTranslations != null) {
          int itemsLength = 0;

          for (int i = 0, l = state.otherTranslations.length; i < l; i++) {
            final List<dynamic> translations = state.otherTranslations[i][2];
            itemsLength += translations.length;
          }

          return TranslationViewContainer(
            title: state.word,
            entity: 'translations',
            itemsLength: itemsLength,
            maxItemsToShow: SHOW_MIN_TRANSLATIONS,
            childBuilder: (bool expanded) => ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) => OtherTranslationsCategory(
                category: state.otherTranslations[index],
                expanded: expanded,
              ),
              itemCount: state.otherTranslations.length,
            ),
          );
        }

        return Container();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              bottom: 5,
            ),
            child: Text(
              '${categoryName[0].toUpperCase()}${categoryName.substring(1)}',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(66, 133, 224, 1),
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
