import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/utils//images.dart';

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
    new Future.delayed(Duration(milliseconds: 100), () {
      Scrollable.ensureVisible(
        itemKey.currentContext,
        duration: Duration(seconds: 1),
        alignment: 0.5
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
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
                          color: isActive ? Colors.greenAccent : Colors.white,
                          padding: EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          child: Center(
                            child: FlatButton(
                              child: Image.memory(getImageBytesFrom64String(imageSource)),
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
                      color: Colors.white,
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
                          child: FlatButton(
                            child: Icon(Icons.arrow_back),
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
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          margin: EdgeInsets.only(left: 10),
                          child: FlatButton(
                            child: Icon(Icons.clear),
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
                      color: Colors.white,
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
}