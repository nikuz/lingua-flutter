import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/router.dart';
import 'package:lingua_flutter/widgets/pronunciation/pronunciation.dart';
import 'package:lingua_flutter/utils//images.dart';

import './bloc/bloc.dart';
import './bloc/state.dart';

class TranslationViewHeader extends StatefulWidget {
  @override
  _TranslationViewHeaderState createState() => _TranslationViewHeaderState();
}

class _TranslationViewHeaderState extends State<TranslationViewHeader> {
  OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        if (state is TranslationLoaded) {
          final String translationWord = state.translationWord;
          final List<dynamic> highestRelevantTranslation = state.highestRelevantTranslation;
          final bool verified = translationWord == highestRelevantTranslation[0][0]
            && highestRelevantTranslation[0][4] != 0;
          String pronunciation = state.pronunciation;
          String imageSource = state.image;
          String transcription;

          if (highestRelevantTranslation[1] != null && highestRelevantTranslation[1].length >= 4) {
            transcription = highestRelevantTranslation[1][3];
          }

          Widget image = Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          );

          if (imageSource != null) {
            image = CompositedTransformTarget(
              link: this._layerLink,
              child: getImage(imageSource),
            );
          }

          return Container(
            color: Colors.blue,
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
                  child: FlatButton(
                    child: Container(
                      width: 150,
                      height: 150,
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: image,
                    ),
                    onPressed: () {
                      if (state.id != null) {
                        this._overlayEntry = this._createOverlayEntry(imageSource);
                        Overlay.of(context).insert(this._overlayEntry);
                      } else {
                        Navigator.pushNamed(
                          context,
                          TRANSLATION_VIEW_IMAGES_PICKER,
                          arguments: state.imageSearchWord,
                        );
                      }
                    },
                  )
                ),
                Center(
                  child: Wrap(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Text(
                        state.translationWord != null ? state.translationWord : '',
                        style: TextStyle(
                          fontFamily: 'Merriweather',
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 1,
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
                Row(
                  children: [
                    PronunciationWidget(
                      pronunciationUrl: pronunciation != null ? pronunciation : '',
                      color: Colors.white,
                      size: 50.0,
                      autoPlay: true,
                    ),
                    Text(
                      transcription != null ? transcription : '',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        }

        return null;
      }
    );
  }

  Image getImage(String imageSource) {
    if (imageSource.indexOf('data:image') == 0) {
      return Image.memory(getImageBytesFrom64String(imageSource));
    } else {
      return Image.network(
        '${getApiUri()}$imageSource',
        fit: BoxFit.fitHeight,
      );
    }
  }

  OverlayEntry _createOverlayEntry(String imageSource) => OverlayEntry(
    builder: (context) => Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width,
      child: Material(
        elevation: 4.0,
        child: FlatButton(
          child: Container(
            width: 300,
            height: 300,
            child: getImage(imageSource),
          ),
          onPressed: () {
            this._overlayEntry.remove();
          },
        ),
      ),
    )
  );
}
