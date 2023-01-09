import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';
import '../../translation_view_state.dart';

class TranslationViewAlternativeTranslationsItem extends StatelessWidget {
  final TranslationAlternativeTranslationItem item;
  final bool isLast;

  const TranslationViewAlternativeTranslationsItem({
    Key? key,
    required this.item,
    required this.isLast,
  }) : super(key: key);

  Widget _buildWordsList(BuildContext context, List<String> words) {
    final MyTheme theme = Styles.theme(context);
    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 7,
      children: [
        Text(
          [...words, 'man'].join(', '),
          style: TextStyle(
            fontSize: 14,
            color: theme.colors.primary.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyBarItem(BuildContext context, bool active) {
    final MyTheme theme = Styles.theme(context);
    return Container(
      width: 10,
      height: 3,
      margin: const EdgeInsets.only(top: 2, right: 1),
      decoration: BoxDecoration(
        color: active
            ? theme.colors.focus
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

        final MyTheme theme = Styles.theme(context);
        final translationViewState = TranslationViewInheritedState.of(context);
        final bool frequencySecondActive = item.frequency == 1 || item.frequency == 2;
        final bool frequencyThirdActive = item.frequency == 1;
        BorderRadius? borderRadius;

        if (isLast) {
          borderRadius = const BorderRadius.vertical(
            top: Radius.circular(0),
            bottom: Radius.circular(8),
          );
        }

        return Material(
          borderRadius: borderRadius,
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: () {
              final newTranslation = '${item.genre != null ? '${item.genre} ' : ''}${item.translation}';
              if (newTranslation != translation.translation) {
                context.read<TranslationViewCubit>().setOwnTranslation(newTranslation);

                if (translationViewState != null && translationViewState.headerKey.currentContext != null) {
                  WidgetsBinding.instance.addPostFrameCallback((dynamic) {
                    Scrollable.ensureVisible(
                      translationViewState.headerKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      alignment: 1,
                    );
                  });
                }
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
                        child: RichText(
                          maxLines: 2,
                          text: TextSpan(
                            style: TextStyle(
                              color: theme.colors.primary,
                            ),
                            children: [
                              if (item.genre != null)
                                TextSpan(
                                  text: '${item.genre!} ',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),

                              TextSpan(
                                text: item.translation,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
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
                          children: [
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
                    child: _buildWordsList(context, item.words),
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
