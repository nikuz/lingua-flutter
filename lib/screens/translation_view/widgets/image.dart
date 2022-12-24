import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/image_preview/image_preview.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';

class TranslationViewImage extends StatelessWidget {
  const TranslationViewImage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        String? imageSource = state.translation?.image;
        final hasImage = imageSource != null || state.imageError != null;
        Widget imageWidget = Container();

        if (state.imageLoading) {
          imageWidget = const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          );
        } else if (hasImage) {
          final editable = state.translation?.id == null || state.imageIsUpdated;
          imageWidget = Material(
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


        return Center(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 100,
              minWidth: 100,
              maxHeight: 150,
            ),
            margin: const EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: imageWidget,
          ),
        );
      },
    );
  }
}
