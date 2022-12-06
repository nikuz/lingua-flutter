import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/widgets/text_field/text_field.dart';
import 'package:lingua_flutter/utils/convert.dart';

import '../bloc/translation_view_cubit.dart';
import '../bloc/translation_view_state.dart';

class TranslationViewImagePicker extends StatefulWidget {
  final String word;

  TranslationViewImagePicker({
    Key? key,
    required this.word,
  }) : super(key: key);

  @override
  _TranslationViewImagePickerState createState() => _TranslationViewImagePickerState();
}

class _TranslationViewImagePickerState extends State<TranslationViewImagePicker> {
  late TranslationViewCubit _translationViewCubit;
  final itemKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    _translationViewCubit = context.read<TranslationViewCubit>();
    final images = _translationViewCubit.state.images;
    if (images == null || images.isEmpty) {
      _translationViewCubit.fetchImages(widget.word);
    }

    new Future.delayed(Duration(milliseconds: 100), this._scrollToSelectedItem);
  }

  void _scrollToSelectedItem() {
    if (_translationViewCubit.state.imageLoading == false && itemKey.currentContext != null) {
      Scrollable.ensureVisible(
        itemKey.currentContext!,
        duration: Duration(seconds: 1),
        alignment: 0.5,
      );
    } else {
      new Future.delayed(Duration(milliseconds: 100), this._scrollToSelectedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<TranslationViewCubit, TranslationViewState>(
          builder: (context, state) {
            final images = state.images;
            Widget imagesList = Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            );

            if (!state.imageLoading && images != null) {
              imagesList = SingleChildScrollView(
                child: Column(
                  children: List<Widget>.generate(
                    images.length,
                    (index) {
                      final String imageSource = images[index];
                      final bool isActive = state.translation?.image == imageSource;
                      return Container(
                        key: isActive ? itemKey : Key(index.toString()),
                        color: isActive ? Colors.greenAccent : Theme.of(context).scaffoldBackgroundColor,
                        padding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        child: Center(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Image.memory(getBytesFrom64String(imageSource)),
                            onPressed: () {
                              _translationViewCubit.setImage(imageSource);
                              AutoRouter.of(context).pop();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }

            return Column(
                children: <Widget>[
                  CustomTextField(
                    defaultValue: widget.word,
                    hintText: 'Search for images...',
                    textInputAction: TextInputAction.search,
                    prefixIcon: Icon(
                      Icons.arrow_back,
                      size: 25,
                    ),
                    prefixAction: () {
                      AutoRouter.of(context).pop();
                    },
                    onSubmitted: (String value) {
                      if (value.isNotEmpty && value != state.imageSearchWord) {
                        _translationViewCubit.fetchImages(value);
                      }
                    },
                  ),
                  Expanded(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: imagesList,
                    ),
                  ),
                ]
            );
          },
        ),
      ),
    );
  }
}
