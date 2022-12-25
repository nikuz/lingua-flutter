import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/image_preview/image_preview.dart';
import 'package:lingua_flutter/widgets/resize_container/resize_container.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';

class TranslationViewImage extends StatefulWidget {
  const TranslationViewImage({super.key});

  @override
  State<TranslationViewImage> createState() => _TranslationViewImageState();
}

class _TranslationViewImageState extends State<TranslationViewImage> {
  Size _size = const Size(100, 100);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null) {
          return Container();
        }

        final MyTheme theme = Styles.theme(context);
        String? imageSource = translation.image;
        final bool isNewWord = translation.id == null;
        final hasImage = imageSource != null || state.imageError != null;
        final editable = translation.id == null || state.imageIsUpdated;
        const constraints = BoxConstraints(
          minHeight: 80,
          minWidth: 100,
          maxHeight: 150,
        );
        Widget imageWidget = Container();

        if (hasImage) {
          imageWidget = Material(
            color: theme.colors.focusBackground,
            elevation: editable ? 5 : 0,
            child: ImagePreview(
              imageSource: imageSource,
              errorIconColor: Styles.colors.white,
              withPreviewOverlay: !editable,
              onTap: () {
                if (editable && state.imageSearchWord != null && state.imageError == null) {
                  AutoRouter.of(context).push(TranslationViewImagePickerRoute(word: state.imageSearchWord!));
                }
              },
            ),
          );
        }

        return Container(
          constraints: const BoxConstraints(
            minHeight: 150,
            minWidth: 150,
          ),
          child: Stack(
            children: [
              if (state.imageLoading)
                Center(
                  child: SizedBox(
                    width: _size.width,
                    height: _size.height,
                    child: const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),

              if (!state.imageLoading && hasImage && isNewWord)
                Opacity(
                  opacity: 0,
                  child: ResizeContainer(
                    onChange: (Size childSize) {
                      setState(() {
                        _size = childSize;
                      });
                    },
                    child: Container(
                      constraints: constraints,
                      child: imageWidget,
                    ),
                  ),
                ),

              if (!state.imageLoading && hasImage)
                Center(
                  child: AnimatedContainer(
                    duration: isNewWord ? const Duration(milliseconds: 150) : Duration.zero,
                    curve: Curves.easeInOutQuad,
                    width: isNewWord ? _size.width : null,
                    height: isNewWord ? _size.height : null,
                    margin: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    constraints: constraints,
                    child: imageWidget,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
