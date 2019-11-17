import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/bloc.dart';
import './bloc/state.dart';
import './widgets/container.dart';
import './widgets/category.dart';

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
              itemBuilder: (BuildContext context, int index) => TranslationViewCategory(
                category: state.otherTranslations[index],
                maxItemsToShow: SHOW_MIN_TRANSLATIONS,
                expanded: expanded,
                itemBuilder: (BuildContext context, int itemIndex) {
                  final category = state.otherTranslations[index];
                  final List<dynamic> translations = category[2];

                  return OtherTranslationsItem(
                    item: translations[itemIndex],
                  );
                }
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
