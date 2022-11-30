import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/pronunciation.dart';
import 'package:lingua_flutter/widgets/image_preview.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_state.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';

class TranslationViewHeader extends StatefulWidget {
  final String word;

  TranslationViewHeader({
    Key? key,
    required this.word,
  }) : super(key: key);

  @override
  _TranslationViewHeaderState createState() => _TranslationViewHeaderState();
}

class _TranslationViewHeaderState extends State<TranslationViewHeader> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final MyTheme theme = Styles.theme(context);
        final String? translationWord = (
            state.translationOwn != null ? state.translationOwn : state.translationWord
        );
        final bool cyrillicWord = state.word is String
            ? state.word!.isCyrillic()
            : false;

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
                  child: _buildImage(state),
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
                          if (cyrillicWord == true) {
                            AutoRouter.of(context).replace(TranslationViewRoute(word: translationWord));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _buildFooter(state),
            ],
          ),
        );
      }
    );
  }

  Widget _buildImage(TranslationViewState state) {
    final bool cyrillicWord = state.word is String
        ? state.word!.isCyrillic()
        : false;
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

    if (state.image != null) {
      image = ImagePreview(
        width: 150,
        height: 150,
        imageSource: state.image!,
        withPreviewOverlay: state.id != null && !state.imageUpdated,
        onTap: () {
          if (state.id == null || state.imageUpdated) {
            AutoRouter.of(context).push(TranslationViewImagePickerRoute(word: state.imageSearchWord));
          }
        },
      );
    }

    return image;
  }

  Widget _buildFooter(TranslationViewState state) {
    final bool cyrillicWord = state.word is String
        ? state.word!.isCyrillic()
        : false;
    final String? pronunciation = state.pronunciation;
    final bool? imageUpdate = state.imageUpdated;
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
    bool toSave = newWord || state.imageUpdated || translationUpdate;
    IconData iconName = Icons.check;
    if (newWord) {
      iconName = Icons.save_alt;
    } else if (state.imageUpdated || translationUpdate) {
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
                  if (pronunciation != null) {
                    return PronunciationWidget(
                      pronunciationSource: pronunciation,
                      color: Colors.blue,
                      size: 45,
                      autoPlay: state.pronunciationAutoPlay,
                    );
                  }
                  return Container();
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
              if (newWord && state.translationWord != null) {
                // context.read<TranslationViewCubit>().save(
                //   Translation(
                //     word: state.word,
                //     translation: state.translationWord!,
                //     pronunciation: pronunciation ?? '',
                //     image: state.image ?? '',
                //     raw: state.raw ?? [],
                //     version: state.version ?? 'v2',
                //   )
                // );
              } else if (imageUpdate! || translationUpdate) {
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
