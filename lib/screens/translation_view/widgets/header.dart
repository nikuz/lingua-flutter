import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:jmespath/jmespath.dart' as jmespath;

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

  TranslationViewHeader({
    Key? key,
    required this.word,
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

          final MyTheme theme = Styles.theme(context);
          String? translationWord = translation.translation ?? jmespath.search(
              schema.translation.translation.value,
              translation.raw
          );

          return Container(
            color: theme.colors.focus,
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
                            translationWord ?? '',
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
                            // AutoRouter.of(context).replace(TranslationViewRoute(word: translationWord));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFooter(context, state),
              ],
            ),
          );
        }
    );
  }

  Widget _buildImage(BuildContext context, TranslationViewState state) {
    if (state.imageLoading) {
      return Center(
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
    final schema = translation?.schema;

    if (translation == null || schema == null) {
      return Container();
    }

    String? pronunciation = state.translation?.pronunciation;
    String? transcription = jmespath.search(schema.translation.transcription.value, translation.raw);

    final bool newWord = translation.id == null;
    bool toSave = newWord || state.imageIsUpdated || state.translationIsUpdated;
    IconData iconName = Icons.check;
    if (newWord) {
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
                  if (pronunciation != null) {
                    return PronunciationWidget(
                      pronunciationSource: pronunciation,
                      color: Colors.blue,
                      size: 45,
                      autoPlay: state.pronunciationAutoPlay,
                    );
                  }
                  return Container();
                },
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Text(
                  transcription ?? '',
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
              if (newWord && state.translation != null) {
                context.read<TranslationViewCubit>().save(state.translation!).then((dynamic) {
                  AutoRouter.of(context).pop<Translation>(state.translation);
                });
              } else if (state.imageIsUpdated || state.translationIsUpdated) {
                // context.read<TranslationViewCubit>().update(
                //   Translation(
                //     word: state.word ?? '',
                //     translation: translationUpdate ? state.translationOwn : state.translationWord,
                //     image: imageUpdate ? state.image : null,
                //   )
                // );
              }
            },
          )
        ],
      ),
    );
  }
}
