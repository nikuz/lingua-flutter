import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

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
  TextEditingController? _textController;
  late TranslationViewCubit _translationViewCubit;
  final itemKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.word);
    _translationViewCubit = context.read<TranslationViewCubit>();
    final images = _translationViewCubit.state.images;
    if (images == null || images.isEmpty) {
      _translationViewCubit.fetchImages(widget.word);
    }

    new Future.delayed(Duration(milliseconds: 100), this._scrollToSelectedItem);
  }

  @override
  void dispose() {
    _textController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 50,
                          margin: EdgeInsets.only(right: 10),
                          child: TextButton(
                            child: Icon(
                              Icons.arrow_back,
                              size: 25,
                            ),
                            onPressed: () {
                              AutoRouter.of(context).pop();
                            },
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            autocorrect: false,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (String value) {
                              if (value.length > 1 && value != state.imageSearchWord) {
                                _translationViewCubit.fetchImages(value);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Search image',
                              hintStyle: TextStyle(
                                fontSize: 20,
                              ),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 20,
//                              color: Colors.black
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          margin: EdgeInsets.only(left: 10),
                          child: TextButton(
                            child: Icon(
                              Icons.clear,
                              size: 25,
                            ),
                            onPressed: () {
                              if (_textController!.text != '') {
                                _textController!.text = '';
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: imagesList
                    ),
                  ),
                ]
            );
          },
        ),
      ),
    );
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
}
