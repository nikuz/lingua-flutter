import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/utils/sizes.dart';
import 'package:lingua_flutter/utils/convert.dart';

import 'bloc/bloc.dart';
import 'bloc/events.dart';
import 'bloc/state.dart';

class TranslationViewImagePicker extends StatefulWidget {
  final String word;

  TranslationViewImagePicker(this.word) : assert(word != null);

  @override
  _TranslationViewImagePickerState createState() => _TranslationViewImagePickerState();
}

class _TranslationViewImagePickerState extends State<TranslationViewImagePicker> {
  TextEditingController _textController;
  TranslationBloc _translationBloc;
  final itemKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.word);
    _translationBloc = BlocProvider.of<TranslationBloc>(context);
    if (_translationBloc.state is TranslationLoaded && _translationBloc.state.images.length == 0) {
      _translationBloc.add(
          TranslationRequestImage(widget.word)
      );
    }

    new Future.delayed(Duration(milliseconds: 100), this._scrollToSelectedItem);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<TranslationBloc, TranslationState>(
          builder: (context, state) {
            if (state is TranslationLoaded) {
              Widget imagesList = Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              );

              if (state.imageLoading == false) {
                imagesList = SingleChildScrollView(
                  child: Column(
                    children: List<Widget>.generate(
                      state.images.length,
                      (index) {
                        final String imageSource = state.images[index];
                        final bool isActive = state.image == imageSource;
                        return Container(
                          key: isActive ? itemKey : Key(index.toString()),
                          color: isActive ? Colors.greenAccent : Theme.of(context).scaffoldBackgroundColor,
                          padding: EdgeInsets.only(
                            top: SizeUtil.vmax(10),
                            bottom: SizeUtil.vmax(10),
                          ),
                          child: Center(
                            child: FlatButton(
                              child: Image.memory(getBytesFrom64String(imageSource)),
                              onPressed: () {
                                _translationBloc.add(
                                    TranslationSelectImage(imageSource)
                                );
                                Navigator.pop(context, false);
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
                          width: SizeUtil.vmax(50),
                          margin: EdgeInsets.only(right: SizeUtil.vmax(10)),
                          child: FlatButton(
                            child: Icon(
                              Icons.arrow_back,
                              size: SizeUtil.vmax(25),
                            ),
                            onPressed: () {
                              Navigator.pop(context, false);
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
                                _translationBloc.add(
                                    TranslationRequestImage(value)
                                );
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Search image',
                              hintStyle: TextStyle(
                                fontSize: SizeUtil.vmax(20),
                              ),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: SizeUtil.vmax(20),
//                              color: Colors.black
                            ),
                          ),
                        ),
                        Container(
                          width: SizeUtil.vmax(50),
                          margin: EdgeInsets.only(left: SizeUtil.vmax(10)),
                          child: FlatButton(
                            child: Icon(
                              Icons.clear,
                              size: SizeUtil.vmax(25),
                            ),
                            onPressed: () {
                              if (_textController.text != '') {
                                _textController.text = '';
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
            }

            return Container();
          },
        ),
      ),
    );
  }

  void _scrollToSelectedItem() {
    if (
        _translationBloc.state is TranslationLoaded
        && _translationBloc.state.imageLoading == false
    ) {
      Scrollable.ensureVisible(
        itemKey.currentContext,
        duration: Duration(seconds: 1),
        alignment: 0.5,
      );
    } else {
      new Future.delayed(Duration(milliseconds: 100), this._scrollToSelectedItem);
    }
  }
}
