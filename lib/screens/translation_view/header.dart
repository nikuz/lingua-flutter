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
                Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        right: 15,
                      ),
                      child: Text(
                        state.translationWord != null ? state.translationWord : '',
                        style: TextStyle(
                          fontFamily: 'Merriweather',
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Icon(
                      verified ? Icons.check_circle_outline : null,
                      color: Colors.white,
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: transcription != null ? 10 : 0,
                  ),
                  child: Text(
                    transcription != null ? transcription : '',
                    style: TextStyle(
                      fontSize: transcription != null ? 15 : 0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    pronunciation != null ?
                      PronunciationWidget(
                        pronunciationUrl: pronunciation,
                        color: Colors.white,
                      )
                      : null,
                    Container(
                      width: 150,
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
