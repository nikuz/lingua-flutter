import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/widgets/pronunciation/pronunciation.dart';
import 'package:lingua_flutter/widgets/image_preview/image_preview.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_state.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';

class TranslationViewHeader extends StatelessWidget {
  final String word;

  const TranslationViewHeader({
    Key? key,
    required this.word,
  }) : super(key: key);

  Widget _buildLanguageSource(TranslationViewState state) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        if (!settingsState.showLanguageSource || state.translation == null) {
          return Container();
        }

        return Positioned(
          top: 10,
          right: 0,
          left: 0,
          child: DefaultTextStyle(
            style: TextStyle(
              color: Styles.colors.paleGrey.withOpacity(0.7),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(state.translation!.translateFrom.value),
                Text(state.translation!.translateTo.value),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(BuildContext context, TranslationViewState state) {
    if (state.imageLoading) {
      return const Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
      );
    }

    String? imageSource = state.translation?.image;
    if (imageSource != null) {
      return ImagePreview(
        width: 150,
        height: 150,
        imageSource: imageSource,
        withPreviewOverlay: state.translation?.id != null && !state.imageIsUpdated,
        onTap: () {
          if ((state.translation?.id == null || state.imageIsUpdated) && state.imageSearchWord != null) {
            AutoRouter.of(context).push(TranslationViewImagePickerRoute(word: state.imageSearchWord!));
          }
        },
      );
    }

    return Container();
  }

  Widget _buildFooter(BuildContext context, TranslationViewState state) {
    final translation = state.translation;

    if (translation == null) {
      return Container();
    }

    final MyTheme theme = Styles.theme(context);
    final bool isNewWord = translation.id == null;
    bool toSave = isNewWord || state.imageIsUpdated || state.translationIsUpdated;
    IconData iconName = Icons.check;
    String? transcription = translation.transcription;

    if (isNewWord) {
      iconName = Icons.save_alt;
    } else if (state.imageIsUpdated || state.translationIsUpdated) {
      iconName = Icons.update;
    }

    Widget icon = Icon(
      iconName,
      color: toSave ? Colors.green : Colors.white,
      size: 35,
    );

    if (state.updateLoading == true) {
      icon = const CircularProgressIndicator(
        backgroundColor: Colors.white,
      );
    }

    if (transcription != null && transcription.length > 100) {
      transcription = transcription.substring(0, 100);
    }

    return Container(
      margin: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              children: [
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, settingsState) {
                    return PronunciationWidget(
                      pronunciationSource: state.translation?.pronunciation,
                      color: Colors.blue,
                      size: 45,
                      autoPlay: settingsState.pronunciationAutoPlay,
                    );
                  },
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Text(
                      transcription ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(65, 65),
              padding: EdgeInsets.zero,
              backgroundColor: toSave
                  ? Colors.white
                  : theme.colors.focusBackground,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(45),
                ),
              ),
            ),
            child: icon,
            onPressed: () {
              if (state.translation != null) {
                if (isNewWord) {
                  context.read<TranslationViewCubit>().save(state.translation!).then((dynamic) {
                    AutoRouter.of(context).pop<TranslationContainer>(state.translation);
                  });
                } else if (state.imageIsUpdated || state.translationIsUpdated) {
                  context.read<TranslationViewCubit>().update(state.translation!).then((dynamic) {
                    AutoRouter.of(context).pop<TranslationContainer>(state.translation!.copyWith(
                      updatedAt: DateTime.now().toString(),
                    ));
                  });
                }
              }
            },
          )
        ],
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

        return Container(
          color: theme.colors.focusBackground,
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Stack(
            children: [
              _buildLanguageSource(state),

              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      margin: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: _buildImage(context, state),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.85,
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              translation.translation.split(', ').join('\n'),
                              style: const TextStyle(
                                fontFamily: 'Merriweather',
                                fontSize: 20,
                                letterSpacing: 1,
                                color: Colors.blue,
                              ),
                            ),
                            onPressed: () {
                              context.read<TranslationViewCubit>().reset();
                              String translationWord = translation.translation;

                              // if translation contains gender-specific variants, then take first word from alternative translations instead
                              if (translationWord.contains(',')) {
                                final firstRelativeTranslation = translation.alternativeTranslations?[0].items[0];
                                if (firstRelativeTranslation != null) {
                                  translationWord = firstRelativeTranslation.translation;
                                }
                              }

                              AutoRouter.of(context).replace(TranslationViewRoute(
                                word: translationWord,
                                translateFrom: translation.translateTo,
                                translateTo: translation.translateFrom,
                              ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildFooter(context, state),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
