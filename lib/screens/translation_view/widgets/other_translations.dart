import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';
import '../models/translation.model.dart';
import './container.dart';
import './category.dart';

const SHOW_MIN_TRANSLATIONS = 5;

class OtherTranslations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        if (state.otherTranslations != null) {
          int itemsAmount = 0;
          int categoriesAmount = state.otherTranslations!.length;

          for (int i = 0, l = categoriesAmount; i < l; i++) {
            List<dynamic>? translations;
            if (state.version == 1) {
              translations = state.otherTranslations![i][2];
            } else if (state.version == 2) {
              translations = state.otherTranslations![i][1];
            }
            itemsAmount += translations!.length;
          }

          return TranslationViewContainer(
            title: state.word,
            entity: 'translations',
            itemsAmount: itemsAmount,
            maxItemsToShow: SHOW_MIN_TRANSLATIONS * categoriesAmount,
            childBuilder: (bool expanded) => ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) => TranslationViewCategory(
                category: state.otherTranslations![index],
                maxItemsToShow: SHOW_MIN_TRANSLATIONS,
                expanded: expanded,
                itemBuilder: (BuildContext context, int itemIndex) {
                  final category = state.otherTranslations![index];
                  List<dynamic>? translations;

                  if (state.version == 1) {
                    translations = category[2];
                  } else if (state.version == 2) {
                    translations = category[1];
                  }

                  return OtherTranslationsItem(
                    state: state,
                    item: translations![itemIndex],
                  );
                }
              ),
              itemCount: state.otherTranslations!.length,
            ),
          );
        }

        return Container();
      }
    );
  }
}

class OtherTranslationsItem extends StatelessWidget {
  final TranslationViewState state;
  final List<dynamic> item;

  OtherTranslationsItem({
    Key? key,
    required this.state,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String word = item[0];
    late List<dynamic> synonyms;
    double? frequency;
    bool frequencySecondActive = false;
    bool frequencyThirdActive = false;

    if (state.version == 1) {
      if (item[1] != null) {
        synonyms = item[1];
      }
      if (item.length >= 4 && item[3] != null) {
        frequency = item[3].toDouble();
        frequencySecondActive = frequency! > 0.001;
        frequencyThirdActive = frequency > 0.1;
      }
    } else if (state.version == 2) {
      if (item[2] != null) {
        synonyms = item[2];
        if (item.length >= 4 && item[3] != null) {
          frequency = item[3].toDouble();
          frequencySecondActive = frequency == 1 || frequency == 2;
          frequencyThirdActive = frequency == 1;
        }
      }
    }

    final bool cyrillicWord = isCyrillicWord(word);
    final double screenWidth = MediaQuery.of(context).size.width;

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
            width: screenWidth * 0.40,
            margin: EdgeInsets.only(right: screenWidth * 0.01),
            child: GestureDetector(
              child: Text(
                word,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontFamily: cyrillicWord ? 'Merriweather' : 'Montserrat',
                  fontSize: 18,
                ),
              ),
              onTap: () {
                if (isCyrillicWord(state.word!)) {
                  AutoRouter.of(context).replace(TranslationViewRoute(word: word));
                } else if (state.id == null) {
                  context.read<TranslationViewCubit>().save(
                      Translation(
                        word: state.word!,
                        translation: word,
                        pronunciation: state.pronunciation ?? '',
                        image: state.image ?? '',
                        raw: state.raw ?? [],
                        version: state.version ?? 2,
                      )
                  );
                } else {
                  context.read<TranslationViewCubit>().update(
                      Translation(
                        word: word,
                        translation: state.translationWord,
                        image: state.image,
                      )
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                top: 4,
              ),
              child: _getSynonymsList(synonyms, screenWidth),
            ),
          ),
          Container(
            width: screenWidth * 0.15,
            padding: EdgeInsets.only(
              top: 8,
              left: screenWidth * 0.01,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _getFrequencyBarItem(context, true, screenWidth),
                _getFrequencyBarItem(context, frequencySecondActive, screenWidth),
                _getFrequencyBarItem(context, frequencyThirdActive, screenWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSynonymsList(List<dynamic> synonyms, double screenWidth) {
    List<Widget> list = [];
    for (int i = 0, l = synonyms.length; i < l; i++) {
      list.add(
          Text(
            i == l - 1 ? synonyms[i] : '${synonyms[i]}, ',
            style: TextStyle(
              fontSize: 14,
            ),
          )
      );
    }

    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 7,
      children: list,
    );
  }

  Widget _getFrequencyBarItem(BuildContext context, bool active, double screenWidth) {
    return Container(
      width: screenWidth * 0.02,
      height: 3,
      margin: EdgeInsets.only(right: screenWidth * 0.002),
      decoration: BoxDecoration(
        color: active
          ? Theme.of(context).buttonTheme.colorScheme?.secondaryContainer
          : Color.fromRGBO(218, 220, 224, 1),
        borderRadius: BorderRadius.all(Radius.circular(1)),
      ),
    );
  }
}
