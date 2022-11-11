import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/widgets/pronunciation.dart';
import 'package:lingua_flutter/widgets/resizable_image.dart';
import 'package:lingua_flutter/utils/string.dart';

import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_state.dart';

import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';
import '../models/translation.model.dart';

class TranslationViewHeader extends StatefulWidget {
  final String word;

  TranslationViewHeader(this.word);

  @override
  _TranslationViewHeaderState createState() => _TranslationViewHeaderState();
}

class _TranslationViewHeaderState extends State<TranslationViewHeader> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final String? translationWord = (
            state.translationOwn != null ? state.translationOwn : state.translationWord
        );
        bool verified = false;
        final List<dynamic>? highestRelevantTranslation = state.highestRelevantTranslation;
        if (highestRelevantTranslation != null) {
          verified = translationWord == highestRelevantTranslation[0][0] && highestRelevantTranslation[0][4] != 0;
        }
        final bool cyrillicWord = state.word is String
            ? isCyrillicWord(state.word!)
            : false;
        final String? imageSource = state.image;

        Widget image = Container();

        if (state.imageLoading) {
          image = Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          );
        }

        if (cyrillicWord == true || state.strangeWord) {
          image = Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 100,
            ),
          );
        }

        if (imageSource != null) {
          image = ResizableImage(
            width: 150,
            height: 150,
            imageSource: imageSource,
            isLocal: !state.remote!,
            withPreviewOverlay: state.id != null && !state.imageUpdate!,
            onTap: () {
              if (state.id == null || state.imageUpdate!) {
                // Navigator.pushNamed(
                //   context,
                //   SearchNavigatorRoutes.translation_view_images_picker,
                //   arguments: {
                //     'word': state.imageSearchWord,
                //   },
                // );
              }
            },
          );
        }

        return Container(
          color: Theme.of(context).primaryColor,
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  margin: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: image,
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        left: verified ? 30 : 0,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          translationWord != null ? translationWord : '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                          style: TextStyle(
                            fontFamily: 'Merriweather',
                            fontSize: 20,
                            letterSpacing: 1,
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: () {
                          if (cyrillicWord == true) {
                            // Navigator.pushReplacementNamed(
                            //   context,
                            //   SearchNavigatorRoutes.translation_view,
                            //   arguments: {
                            //     'word': translationWord,
                            //   },
                            // );
                          }
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: verified ? 5 : 0,
                      ),
                      child: Icon(
                        verified ? Icons.check_circle_outline : null,
                        color: Colors.white,
                        size: verified ? 25 : 0,
                      ),
                    ),
                  ],
                ),
              ),
              _getFooter(state),
            ],
          ),
        );
      }
    );
  }

  Widget _getFooter(TranslationViewState state) {
    final bool cyrillicWord = state.word is String
        ? isCyrillicWord(state.word!)
        : false;
    final String? pronunciation = state.pronunciation;
    final bool? imageUpdate = state.imageUpdate;
    final translationUpdate = (
        state.translationOwn != null && state.translationOwn != state.translationWord
    );

    if (cyrillicWord == true || state.strangeWord) {
      return Container(
        margin: EdgeInsets.only(bottom: 10),
      );
    }

    final bool? remote = state.remote;
    final bool newWord = state.id == null;
    bool toSave = newWord || imageUpdate! || translationUpdate;
    IconData iconName = Icons.check;
    if (newWord) {
      iconName = Icons.save_alt;
    } else if (imageUpdate! || translationUpdate) {
      iconName = Icons.update;
    }

    Widget icon = Icon(
      iconName,
      color: toSave ? Colors.green : Colors.white,
      size: 35,
    );

    if (state.updateLoading == true || state.saveLoading == true) {
      icon = CircularProgressIndicator(
        backgroundColor: Colors.white,
      );
    }

    return Container(
      margin: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return PronunciationWidget(
                    pronunciationUrl: pronunciation ?? '',
                    color: Colors.blue,
                    size: 45,
                    autoPlay: state.pronunciationAutoPlay,
                    isLocal: remote == false,
                  );
                }
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Text(
                  state.transcription != null ? state.transcription! : '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            style: TextButton.styleFrom(
              // padding: EdgeInsets.zero,
              minimumSize: Size(65, 65),
              padding: EdgeInsets.zero,
              backgroundColor: toSave ? Colors.white : Colors.blue,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.all(
                  Radius.circular(45),
                ),
              ),
            ),
            child: icon,
            onPressed: () {
              if (newWord) {
                context.read<TranslationViewCubit>().save(
                  Translation(
                    word: state.word,
                    translation: state.translationWord!,
                    pronunciation: pronunciation ?? '',
                    image: state.image ?? '',
                    raw: state.raw ?? [],
                    version: state.version ?? 2,
                  )
                );
              } else if (imageUpdate! || translationUpdate) {
                context.read<TranslationViewCubit>().update(
                  Translation(
                    word: state.word,
                    translation: translationUpdate ? state.translationOwn : state.translationWord,
                    image: imageUpdate ? state.image : null,
                  )
                );
              }
            },
          )
        ],
      ),
    );
  }
}
