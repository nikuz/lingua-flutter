import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/widgets/pronunciation/pronunciation.dart';

import './bloc/bloc.dart';
import './bloc/state.dart';

class TranslationViewHeader extends StatelessWidget {
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
          String image = state.image;
          String transcription;

          if (highestRelevantTranslation[1] != null && highestRelevantTranslation[1].length >= 4) {
            transcription = highestRelevantTranslation[1][3];
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
                  child: Container(
                    width: 150,
                    height: 150,
                    margin: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: image != null ?
                    Image.network(
                      '${getApiUri()}$image',
                      fit: BoxFit.fitHeight,
                    )
                      : null,
                  ),
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
                )
              ],
            ),
          );
        }

        return null;
      }
    );
  }
}
