import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/widgets/pronunciation/pronunciation.dart';
import 'package:lingua_flutter/widgets/button/button.dart';
import 'package:lingua_flutter/widgets/snack_bar/snack_bar.dart';
import 'package:lingua_flutter/screens/router.gr.dart';
import 'package:lingua_flutter/controllers/local_translation.dart' as local_translate_controller;
import 'package:lingua_flutter/app_config.dart' as config;

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';
import '../../translation_view_state.dart';
import '../auto_language/auto_language.dart';
import '../auto_spelling/auto_spelling.dart';
import '../image/image.dart';

class TranslationViewHeader extends StatefulWidget {
  final String word;

  const TranslationViewHeader({
    Key? key,
    required this.word,
  }) : super(key: key);

  @override
  State<TranslationViewHeader> createState() => _TranslationViewHeaderState();
}

class _TranslationViewHeaderState extends State<TranslationViewHeader> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _retrievePreference();
  }

  void _retrievePreference() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // request review only once when amount of saved words exceeded the threshold set in config.wordsAmountRateThreshold
  void _showRateUsModal() async {
    const settingName = 'askToRateUs';
    if (_prefs != null && _prefs!.getBool(settingName) != true) {
      final amountOfSavedWords = await local_translate_controller.getListLength();
      if (amountOfSavedWords > config.wordsAmountRateThreshold) {
        _prefs!.setBool(settingName, true);
        final inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
        }
      }
    }
  }

  void _saveHandler(TranslationViewState state) {
    final translation = state.translation;
    if (translation == null) {
      return;
    }

    final bool isNewWord = translation.id == null;
    final translationViewState = TranslationViewInheritedState.of(context);

    if (isNewWord) {
      context.read<TranslationViewCubit>().save(translation, translationViewState?.cancelToken).then((dynamic) {
        AutoRouter.of(context).pop<TranslationContainer>(translation);
        CustomSnackBar(context: context, message: 'Word is saved successfully').show();
        _showRateUsModal();
      });
    } else if (state.imageIsUpdated || state.translationIsUpdated) {
      context.read<TranslationViewCubit>().update(translation, translationViewState?.cancelToken).then((dynamic) {
        AutoRouter.of(context).pop<TranslationContainer>(translation.copyWith(
          updatedAt: DateTime.now().toString(),
        ));
        CustomSnackBar(context: context, message: 'Word is updated successfully').show();
      });
    }
  }

  Widget _buildPronunciation(BuildContext context, TranslationViewState state, { bool? from, bool? to }) {
    final translation = state.translation;
    if (translation == null) {
      return Container();
    }

    String language = '';
    String? pronunciationSource;

    if (from == true) {
      language = translation.translateFrom.value;
      pronunciationSource = translation.pronunciationFrom;
    }

    if (to == true) {
      language = translation.translateTo.value;
      pronunciationSource = translation.pronunciationTo;
    }

    return Container(
      width: 80,
      padding: const EdgeInsets.only(top: 10),
      margin: EdgeInsets.only(
        left: from == true ? 10 : 0,
        right: to == true ? 10 : 0,
      ),
      child: Column(
        crossAxisAlignment: from == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 35,
            child: Text(
              language,
              textAlign: from == true ? TextAlign.start : TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Styles.colors.white.withOpacity(0.7),
              ),
            ),
          ),
          PronunciationWidget(
            pronunciationSource: pronunciationSource,
            iconColor: Styles.colors.white.withOpacity(0.7),
            backgroundColor: Colors.transparent,
            size: 45,
            autoPlay: false,
            highlightColor: Styles.colors.white.withOpacity(0.1),
            splashColor: Styles.colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
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
    final alreadySaved = !isNewWord && !state.imageIsUpdated && !state.translationIsUpdated;

    if (isNewWord) {
      iconName = Icons.save_alt;
    } else if (state.imageIsUpdated || state.translationIsUpdated) {
      iconName = Icons.update;
    }

    if (transcription != null && transcription.length > 100) {
      transcription = transcription.substring(0, 100);
    }

    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 5),
              child: Text(
                transcription ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          Button(
            width: 65,
            height: 65,
            icon: iconName,
            iconSize: 35,
            textColor: toSave && !state.updateLoading ? Colors.green : Colors.white,
            backgroundColor: toSave && !state.updateLoading
                ? Colors.white
                : theme.colors.focusBackground,
            disabled: state.translation == null || state.imageLoading || state.pronunciationLoading,
            loading: state.updateLoading,
            outlined: false,
            shape: ButtonShape.oval,
            onPressed: alreadySaved ? null : () {
              _saveHandler(state);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null) {
          return Container();
        }

        final MyTheme theme = Styles.theme(context);

        return Container(
          color: theme.colors.focusBackground,
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPronunciation(context, state, from: true),

                  const Expanded(
                    child: TranslationViewImage(),
                  ),

                  _buildPronunciation(context, state, to: true),
                ],
              ),

              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      // split by gender specific translations
                      translation.translation.split(', ').join('\n'),
                      style: const TextStyle(
                        fontSize: 20,
                        letterSpacing: 1,
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: () {
                      context.read<TranslationViewCubit>().reset();
                      AutoRouter.of(context).replace(TranslationViewRoute(
                        word: translation.mostRelevantTranslation,
                        translateFrom: translation.translateTo,
                        translateTo: translation.translateFrom,
                      ));
                    },
                  ),
                ),
              ),
              _buildFooter(context, state),
              const TranslationViewAutoLanguage(),
              const TranslationViewAutoSpelling(),
            ],
          ),
        );
      },
    );
  }
}
