import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bloc.dart';
import 'bloc/events.dart';

class TranslationViewOwnTranslation extends StatefulWidget {
  final String word;

  TranslationViewOwnTranslation(this.word) : assert(word != null);

  @override
  _TranslationViewOwnTranslationState createState() => _TranslationViewOwnTranslationState();
}

class _TranslationViewOwnTranslationState extends State<TranslationViewOwnTranslation> {
  TextEditingController _textController;
  final itemKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.word);
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                          this.submit();
                        },
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        autocorrect: false,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (String value) {
                          this.submit();
                        },
                        decoration: InputDecoration(
                          hintText: 'Type your translation',
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
            ],
        ),
      ),
    );
  }

  void submit() {
    if (_textController.text != widget.word) {
      BlocProvider.of<TranslationBloc>(context).add(
          TranslationSetOwn(_textController.text)
      );
    }
    Navigator.pop(context, false);
  }
}
