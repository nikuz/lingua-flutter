import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/utils//images.dart';

import './bloc/bloc.dart';
import './bloc/events.dart';
import './bloc/state.dart';

class TranslationViewImagePicker extends StatefulWidget {
  final String word;

  TranslationViewImagePicker(this.word) : assert(word != null);

  @override
  _TranslationViewImagePickerState createState() => _TranslationViewImagePickerState();
}

class _TranslationViewImagePickerState extends State<TranslationViewImagePicker> {
  TextEditingController _textController;
  TranslationBloc _translationBloc;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.word);
    _translationBloc = BlocProvider.of<TranslationBloc>(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TranslationBloc, TranslationState>(
          builder: (context, state) {
            if (state is TranslationLoaded) {
              Widget imagesList = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                ],
              );

              if (state.imageLoading == false) {
                imagesList = ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final String imageSource = state.images[index];

                    return Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.7,
                        margin: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
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
                  itemCount: state.images.length,
                );
              }

              return Column(
                children: <Widget>[
                  TextField(
                    controller: _textController,
                    autocorrect: false,
                    onSubmitted: (String value) {
                      if (value.length > 1 && value != state.word) {
                        _translationBloc.add(
                          TranslationRequestImage(value)
                        );
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: GestureDetector(
                        child: Icon(Icons.arrow_back),
                        onTap: () {
                          Navigator.pop(context, false);
                        },
                      ),
                      suffixIcon: GestureDetector(
                        child: Icon(Icons.clear),
                        onTap: () {
                          if (_textController.text != '') {
                            _textController.text = '';
                          }
                        },
                      ),
                      hintText: 'Search image',
                    ),
                  ),
                  Expanded(child: imagesList),
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
