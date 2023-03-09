import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/controllers/request/request.dart' show CancelToken;
import 'package:lingua_flutter/widgets/text_field/text_field.dart';
import 'package:lingua_flutter/widgets/image_preview/image_preview.dart';
import 'package:lingua_flutter/widgets/tag/tag.dart';
import 'package:lingua_flutter/utils/string.dart';
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
  late TextEditingController _textController;
  CancelToken _cancelToken = CancelToken();
  late String _text;

  @override
  void initState() {
    super.initState();
    _translationViewCubit = context.read<TranslationViewCubit>();
    _textController = TextEditingController();
    _text = widget.word;
    final images = _translationViewCubit.state.images;
    if (images == null || images.isEmpty) {
      _translationViewCubit.fetchImages(widget.word, cancelToken: _cancelToken);
    }

    _scrollToSelectedItem();
  }

  @override
  void dispose() {
    _textController.dispose();
    _cancelToken.cancel();
    if (_translationViewCubit.state.imageLoading) {
      _translationViewCubit.resetImageSearchWord();
    }
    super.dispose();
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

  void _submitNewSearch(String word) {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel();
    }
    _cancelToken = CancelToken();
    _translationViewCubit.fetchImages(word, cancelToken: _cancelToken);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationViewCubit, TranslationViewState>(
      builder: (context, state) {
        final MyTheme theme = Styles.theme(context);
        final isInDarkMode = theme.brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 4,
            backgroundColor: theme.colors.focusBackground,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isInDarkMode ? Brightness.light : Brightness.dark,
              statusBarBrightness: isInDarkMode ? Brightness.dark : Brightness.light,
            ),
            title: CustomTextField(
              controller: _textController,
              defaultValue: widget.word,
              hintText: 'Search for images',
              textInputAction: TextInputAction.search,
              prefixIcon: Icons.arrow_back,
              maxLength: 100,
              borderRadius: BorderRadius.circular(4),
              margin: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
              prefixAction: () {
                AutoRouter.of(context).pop();
              },
              onChanged: (text) {
                setState(() {
                  _text = text;
                });
              },
              onSubmitted: (String value) {
                final sanitizedWord = removeQuotesFromString(removeSlashFromString(value)).trim();
                if (sanitizedWord.isNotEmpty) {
                  if (sanitizedWord != state.imageSearchWord) {
                    _submitNewSearch(sanitizedWord);
                  }
                } else {
                  _textController.clear();
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
                      itemCount: images.length + 1,
                      itemBuilder: (context, index) {
                        final word = state.imageSearchWord;
                        final List<String> tags = [
                          'meme',
                          'meaning',
                        ];
                        final List<String> shownTags = tags.where((item) => _text.contains(item) == false).toList();

                        if (index == 0) {
                          if (word != null && shownTags.isNotEmpty) {
                            String wordWithoutTags = word;
                            for (var tag in tags) {
                              wordWithoutTags = wordWithoutTags.replaceAll(RegExp('\\s?$tag'), '');
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              child: Wrap(
                                children: [
                                  for (var tag in shownTags)
                                    Tag(
                                      text: wordWithoutTags,
                                      suffix: tag,
                                      margin: const EdgeInsets.all(3),
                                      onPressed: (tagWord) {
                                        _submitNewSearch(tagWord);
                                        _textController.text = tagWord;
                                        _textController.selection = TextSelection.fromPosition(
                                          TextPosition(offset: _textController.text.length),
                                        );
                                        setState(() {
                                          _text = tagWord;
                                        });
                                      },
                                    ),
                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }

                        final String imageSource = images[index - 1];
                        final bool isActive = state.translation?.image == imageSource;
                        return Container(
                          key: isActive ? itemKey : Key((index - 1).toString()),
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
