import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/widgets/text_field/text_field.dart';
import 'package:lingua_flutter/widgets/image_preview/image_preview.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';

class TranslationViewImagePicker extends StatefulWidget {
  final String word;

  const TranslationViewImagePicker({
    Key? key,
    required this.word,
  }) : super(key: key);

  @override
  State<TranslationViewImagePicker> createState() => _TranslationViewImagePickerState();
}

class _TranslationViewImagePickerState extends State<TranslationViewImagePicker> {
  late TranslationViewCubit _translationViewCubit;
  final itemKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _translationViewCubit = context.read<TranslationViewCubit>();
    final images = _translationViewCubit.state.images;
    if (images == null || images.isEmpty) {
      _translationViewCubit.fetchImages(widget.word);
    }

    _scrollToSelectedItem();
  }

  void _scrollToSelectedItem() {
    if (_translationViewCubit.state.imageLoading == false && itemKey.currentContext != null) {
      Scrollable.ensureVisible(
        itemKey.currentContext!,
        duration: const Duration(seconds: 1),
        alignment: 0.5,
      );
    } else {
      Future.delayed(const Duration(milliseconds: 100), _scrollToSelectedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final MyTheme theme = Styles.theme(context);
        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 4,
            backgroundColor: theme.colors.focusBackground,
            // elevation: 0,
            title: CustomTextField(
              defaultValue: widget.word,
              hintText: 'Search for images',
              textInputAction: TextInputAction.search,
              prefixIcon: Icons.arrow_back,
              maxLength: 100,
              borderRadius: BorderRadius.circular(4),
              // backgroundColor: theme.colors.cardBackground,
              margin: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
              prefixAction: () {
                AutoRouter.of(context).pop();
              },
              onSubmitted: (String value) {
                if (value.isNotEmpty && value != state.imageSearchWord) {
                  _translationViewCubit.fetchImages(value);
                }
              },
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: Builder(
              builder: (context) {
                final images = state.images;
                Widget imagesList = const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                );

                if (!state.imageLoading && images != null && images.isEmpty) {
                  imagesList = const Center(
                    child: Text(
                      'No images found',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                if (!state.imageLoading && images != null && images.isNotEmpty) {
                  imagesList = SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final String imageSource = images[index];
                        final bool isActive = state.translation?.image == imageSource;
                        return Container(
                          key: isActive ? itemKey : Key(index.toString()),
                          color: isActive ? Styles.colors.grey.withOpacity(0.3) : Colors.transparent,
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          child: Center(
                            child: ImagePreview(
                              imageSource: imageSource,
                              withPreviewOverlay: false,
                              onTap: () {
                                _translationViewCubit.setImage(imageSource);
                                AutoRouter.of(context).pop();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return imagesList;
              },
            ),
          ),
        );
      }
    );
  }
}
