import 'package:flutter/material.dart';

class TranslationView extends StatefulWidget {
  final String word;

  TranslationView(this.word) : assert(word != null);

  @override
  _TranslationViewState createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Text(widget.word),
        ),
      ),
    );
  }
}
