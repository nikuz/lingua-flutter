import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/bloc.dart';
import './bloc/events.dart';
import './bloc/state.dart';

class TranslationView extends StatefulWidget {
  final String word;

  TranslationView(this.word) : assert(word != null);

  @override
  _TranslationViewState createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TranslationBloc>(context).add(TranslationRequest(widget.word));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TranslationBloc, TranslationState>(
          builder: (context, state) {
            if (state is TranslationLoaded) {
              return Row(
                children: <Widget>[
                  Container(
                    child: Text(state.word),
                  ),
                  Container(
                    child: Text(state.translation != null ? state.translation : ''),
                  ),
                ],
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
