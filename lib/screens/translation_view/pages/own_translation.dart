import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/translation_view_cubit.dart';

class TranslationViewOwnTranslation extends StatefulWidget {
  final String word;

  TranslationViewOwnTranslation(this.word);

  @override
  _TranslationViewOwnTranslationState createState() => _TranslationViewOwnTranslationState();
}

class _TranslationViewOwnTranslationState extends State<TranslationViewOwnTranslation> {
  TextEditingController? _textController;
  final itemKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.word);
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
        child: Column(
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
                          hintStyle: TextStyle(
                            fontSize: 20,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: 20,
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
            ],
        ),
      ),
    );
  }

  void submit() {
    if (_textController != null && _textController!.text != widget.word) {
      context.read<TranslationViewCubit>().setOwnTranslation(_textController!.text);
    }
    Navigator.pop(context, false);
  }
}
