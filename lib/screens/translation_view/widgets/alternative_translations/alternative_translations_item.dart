import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:jmespath/jmespath.dart' as jmespath;

import 'package:lingua_flutter/models/translation.dart';
import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';

class TranslationViewAlternativeTranslationsItem extends StatelessWidget {
  final List<dynamic> data;

  TranslationViewAlternativeTranslationsItem({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;
        final schema = translation?.schema;

        if (translation == null || schema == null) {
          return Container();
        }

        final bool isNewWord = translation.id == null;
        String? word = jmespath.search(schema.translation.alternativeTranslations.items.translation.value, data);
        List<dynamic>? words = jmespath.search(schema.translation.alternativeTranslations.items.words.value, data);
        int? frequency = jmespath.search(schema.translation.alternativeTranslations.items.frequency.value, data);

        bool frequencySecondActive = frequency == 1 || frequency == 2;
        bool frequencyThirdActive = frequency == 1;

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
                    word ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    final alteredTranslation = translation.copyWith(
                      translation: word,
                      updatedAt: DateTime.now().toString(),
                    );
                    if (isNewWord) {
                      context.read<TranslationViewCubit>().save(alteredTranslation).then((dynamic) {
                        AutoRouter.of(context).pop<Translation>(alteredTranslation);
                      });
                    } else {
                      context.read<TranslationViewCubit>().update(alteredTranslation).then((dynamic) {
                        AutoRouter.of(context).pop<Translation>(alteredTranslation);
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                    top: 4,
                  ),
                  child: _getWordsList(words, screenWidth),
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
      },
    );
  }

  Widget _getWordsList(List<dynamic>? words, double screenWidth) {
    if (words == null) {
      return Container();
    }
    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 7,
      children: List.generate(words.length, (i) {
        final isLast = i == words.length - 1;
        String separator = ', ';

        if (isLast) {
          separator = '';
        }

        return Text(
          '${words[i]}$separator',
          style: TextStyle(
            fontSize: 14,
          ),
        );
      }),
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
