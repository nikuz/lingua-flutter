import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/screens/search/router.dart';
import 'package:lingua_flutter/widgets/pronunciation.dart';
import 'package:lingua_flutter/widgets/resizable_image.dart';
import 'package:lingua_flutter/helpers/db.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/sizes.dart';

import 'package:lingua_flutter/screens/settings/home/bloc/bloc.dart';
import 'package:lingua_flutter/screens/settings/home/bloc/state.dart';

import 'bloc/bloc.dart';
import 'bloc/state.dart';
import 'bloc/events.dart';

class TranslationViewHeader extends StatefulWidget {
  final String word;

  TranslationViewHeader(this.word) : assert(word != null);

  @override
  _TranslationViewHeaderState createState() => _TranslationViewHeaderState();
}

class _TranslationViewHeaderState extends State<TranslationViewHeader> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        if (state is TranslationLoaded) {
          final String translationWord = (
              state.translationOwn != null ? state.translationOwn : state.translationWord
          );
          final List<dynamic> highestRelevantTranslation = state.highestRelevantTranslation;
          final bool verified = translationWord == highestRelevantTranslation[0][0]
            && highestRelevantTranslation[0][4] != 0;
          final bool cyrillicWord = isCyrillicWord(state.word);
          final String imageSource = state.image;

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
                size: SizeUtil.vmax(100),
              ),
            );
          }

          if (imageSource != null) {
            image = Container(
              margin: EdgeInsets.only(
                top: SizeUtil.vmax(10),
                bottom: SizeUtil.vmax(10),
              ),
              child: ResizableImage(
                  width: 150,
                  height: 150,
                  imageSource: imageSource,
                  updatedAt: state.updatedAt,
                  isLocal: !state.remote,
                  withPreviewOverlay: true,
                  onTap: () {
                    if (state.id == null || state.imageUpdate) {
                      Navigator.pushNamed(
                        context,
                        SearchNavigatorRoutes.translation_view_images_picker,
                        arguments: state.imageSearchWord,
                      );
                    }
                  },
              ),
            );
          }

          return Container(
            color: Theme.of(context).primaryColor,
            width: double.infinity,
            padding: EdgeInsets.only(
              left: SizeUtil.vmax(10),
              right: SizeUtil.vmax(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Center(child: image),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: verified ? SizeUtil.vmax(30) : 0,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.85,
                        ),
                        child: FlatButton(
                          color: Colors.white,
                          textColor: Colors.blue,
                          child: Text(
                            translationWord != null ? translationWord : '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: TextStyle(
                              fontFamily: 'Merriweather',
                              fontSize: SizeUtil.vmax(20),
                              letterSpacing: SizeUtil.vmax(1),
                            ),
                          ),
                          onPressed: () {
                            if (cyrillicWord == true) {
                              Navigator.pushReplacementNamed(
                                context,
                                SearchNavigatorRoutes.translation_view,
                                arguments: translationWord,
                              );
                            }
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: verified ? SizeUtil.vmax(5) : 0,
                        ),
                        child: Icon(
                          verified ? Icons.check_circle_outline : null,
                          color: Colors.white,
                          size: verified ? SizeUtil.vmax(25) : 0,
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

        return Container();
      }
    );
  }

  Widget _getFooter(TranslationLoaded state) {
    final List<dynamic> highestRelevantTranslation = state.highestRelevantTranslation;
    final bool cyrillicWord = isCyrillicWord(state.word);
    final String pronunciation = state.pronunciation;
    final bool imageUpdate = state.imageUpdate;
    final translationUpdate = (
        state.translationOwn != null && state.translationOwn != state.translationWord
    );
    String transcription;

    if (
        highestRelevantTranslation.length > 1
        && highestRelevantTranslation[1] != null
        && highestRelevantTranslation[1].length >= 4
    ) {
      transcription = highestRelevantTranslation[1][3];
    }

    if (cyrillicWord == true || state.strangeWord) {
      return Container(
        margin: EdgeInsets.only(bottom: SizeUtil.vmax(10)),
      );
    }

    final bool remote = state.remote;
    final bool newWord = state.id == null;
    bool translationSavedOnlyRemotely = db != null && remote;
    bool toSave = newWord || imageUpdate || translationUpdate || translationSavedOnlyRemotely;
    IconData iconName = Icons.check;
    if (newWord || translationSavedOnlyRemotely) {
      iconName = Icons.save_alt;
    } else if (imageUpdate || translationUpdate) {
      iconName = Icons.update;
    }

    Widget icon = Icon(
      iconName,
      color: toSave ? Colors.green : Colors.white,
      size: SizeUtil.vmax(35),
    );

    if (state.updateLoading == true || state.saveLoading == true) {
      icon = CircularProgressIndicator(
        backgroundColor: Colors.white,
      );
    }

    return Container(
      margin: EdgeInsets.only(
        top: SizeUtil.vmax(10),
        bottom: SizeUtil.vmax(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state is SettingsLoaded) {
                    return PronunciationWidget(
                      pronunciationUrl: pronunciation != null ? pronunciation : '',
                      color: Colors.blue,
                      size: SizeUtil.vmax(45),
                      autoPlay: state.settings['pronunciationAutoPlay'],
                      isLocal: !remote,
                    );
                  }

                  return CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  );
                }
              ),
              Container(
                margin: EdgeInsets.only(left: SizeUtil.vmax(10)),
                child: Text(
                  transcription != null ? transcription : '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeUtil.vmax(15),
                  ),
                ),
              ),
            ],
          ),
          ButtonTheme(
            minWidth: SizeUtil.vmax(65),
            height: SizeUtil.vmax(65),
            child: FlatButton(
              color: toSave ? Colors.white : Colors.blue,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.all(
                  Radius.circular(SizeUtil.vmax(45)),
                ),
              ),
              child: icon,
              onPressed: () {
                if (newWord || translationSavedOnlyRemotely) {
                  BlocProvider.of<TranslationBloc>(context).add(TranslationSave(
                    word: state.word,
                    translation: state.translationWord,
                    pronunciationURL: pronunciation,
                    image: state.image,
                    raw: state.raw,
                  ));
                } else if (imageUpdate || translationUpdate) {
                  BlocProvider.of<TranslationBloc>(context).add(TranslationUpdate(
                    word: translationUpdate ? state.translationOwn : state.translationWord,
                    image: imageUpdate ? state.image : null,
                  ));
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
