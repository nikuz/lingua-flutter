import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/bloc.dart';
import './bloc/events.dart';
import './bloc/state.dart';

import './header.dart';
import './other_translations.dart';
import './definitions.dart';
import './examples.dart';

class TranslationView extends StatefulWidget {
  final String word;

  TranslationView(this.word) : assert(word != null);

  @override
  _TranslationViewState createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> {
  TranslationBloc _translationBloc;

  @override
  void initState() {
    super.initState();
    _translationBloc = BlocProvider.of<TranslationBloc>(context);
    _translationBloc.add(TranslationRequest(widget.word));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          title: Text('${widget.word[0].toUpperCase()}${widget.word.substring(1)}'),
          leading: IconButton(icon:Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, false);
              BlocProvider.of<TranslationBloc>(context).add(TranslationClear());
            },
          ),
          elevation: 0,
      ),
      body: SafeArea(
        child: BlocListener<TranslationBloc, TranslationState>(
          listener: (context, state) {
            if (state is TranslationLoaded && state.image == null && state.images.isEmpty) {
              _translationBloc.add(TranslationRequestImage(state.word));
            }
          },
          child: BlocBuilder<TranslationBloc, TranslationState>(
            builder: (context, state) {
              if (state is TranslationLoaded) {
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TranslationViewHeader(),
                      OtherTranslations(),
                      Definitions(),
                      Examples(),
                    ],
                  ),
                );
              }

              if (state is TranslationError) {
                return Center(
                  child: Text(state.error.message),
                );
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
