import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/image_preview/image_preview.dart';
import 'package:lingua_flutter/widgets/resize_container/resize_container.dart';
import 'package:lingua_flutter/widgets/button/button.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../../bloc/translation_view_cubit.dart';
import '../../bloc/translation_view_state.dart';

class TranslationViewImage extends StatefulWidget {
  const TranslationViewImage({super.key});

  @override
  State<TranslationViewImage> createState() => _TranslationViewImageState();
}

class _TranslationViewImageState extends State<TranslationViewImage> {
  Size _containerSize = Size.zero;
  Size _imageSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final translation = state.translation;

        if (translation == null) {
          return Container();
        }

        String? imageSource = translation.image;
        final hasImage = imageSource != null && state.imageError == null;
        const double imageVerticalMargin = 10;
        const double editButtonMargin = 2;
        Widget imageWidget = Container();

        if (hasImage) {
          imageWidget = ImagePreview(
            imageSource: imageSource,
            errorIconColor: Styles.colors.white,
          );
        }

        return ResizeContainer(
          onChange: (Size childSize) {
            if (_containerSize == Size.zero) {
              setState(() {
                _containerSize = childSize;
              });
            }
          },
          child: SizedBox(
            height: 150,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                if (state.imageLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  ),

                if (!state.imageLoading && !hasImage)
                  Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Styles.colors.white,
                      size: 75,
                    ),
                  ),

                if (!state.imageLoading && hasImage)
                  Center(
                    child: ResizeContainer(
                      onChange: (Size childSize) {
                        setState(() {
                          _imageSize = childSize;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: imageVerticalMargin),
                        // constraints: constraints,
                        child: imageWidget,
                      ),
                    ),
                  ),

                if (!state.imageLoading && hasImage)
                  Positioned(
                    bottom: (_containerSize.height - _imageSize.height) / 2 + imageVerticalMargin + editButtonMargin,
                    right: (_containerSize.width - _imageSize.width) / 2 + editButtonMargin,
                    child: AnimatedOpacity(
                      opacity: _containerSize != Size.zero && _imageSize != Size.zero ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Button(
                        icon: Icons.edit,
                        textColor: Styles.colors.white,
                        backgroundColor: Styles.colors.black.withOpacity(0.6),
                        shape: ButtonShape.oval,
                        width: 40.0,
                        height: 40.0,
                        outlined: false,
                        onPressed: () {
                          AutoRouter.of(context).push(TranslationViewImagePickerRoute(word: state.imageSearchWord!));
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
