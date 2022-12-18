import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/models/translation.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';

class TranslationViewAlternativeTranslationsItem extends StatelessWidget {
  final TranslationAlternativeTranslationItem item;

  const TranslationViewAlternativeTranslationsItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  Widget _buildWordsList(List<String> words) {
    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 7,
      children: [
        Text(
          [...words, 'man'].join(', '),
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyBarItem(BuildContext context, bool active) {
    return Container(
      width: 10,
      height: 3,
      margin: const EdgeInsets.only(top: 2, right: 1),
      decoration: BoxDecoration(
        color: active
            ? Theme.of(context).buttonTheme.colorScheme?.secondaryContainer
            : const Color.fromRGBO(218, 220, 224, 1),
        borderRadius: const BorderRadius.all(Radius.circular(1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null) {
          return Container();
        }

        final bool isNewWord = translation.id == null;
        final bool frequencySecondActive = item.frequency == 1 || item.frequency == 2;
        final bool frequencyThirdActive = item.frequency == 1;

        return Material(
          child: InkWell(
            onTap: () {
              final alteredTranslation = translation.copyWith(
                translation: '${item.genre != null ? '${item.genre} ' : ''}${item.translation}',
                updatedAt: DateTime.now().toString(),
              );
              if (isNewWord) {
                context.read<TranslationViewCubit>().save(alteredTranslation).then((dynamic) {
                  AutoRouter.of(context).pop<TranslationContainer>(alteredTranslation);
                });
              } else {
                context.read<TranslationViewCubit>().update(alteredTranslation).then((dynamic) {
                  AutoRouter.of(context).pop<TranslationContainer>(alteredTranslation);
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(
                top: 5,
                right: 10,
                bottom: 10,
                left: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (item.genre != null)
                              Text(
                                '${item.genre!} ',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),

                            Text(
                              item.translation,
                              maxLines: 2,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            _buildFrequencyBarItem(context, true),
                            _buildFrequencyBarItem(context, frequencySecondActive),
                            _buildFrequencyBarItem(context, frequencyThirdActive),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.only(top: 4),
                    child: _buildWordsList(item.words),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
