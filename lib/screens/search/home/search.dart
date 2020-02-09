import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/screens/search/router.dart';
import 'package:lingua_flutter/screens/search/translation_view/bloc/bloc.dart';
import 'package:lingua_flutter/screens/search/translation_view/bloc/state.dart';

import 'bloc/bloc.dart';
import 'bloc/events.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _textController = TextEditingController();
  TranslationsBloc _translationsBloc;

  @override
  void initState() {
    super.initState();
    _translationsBloc = BlocProvider.of<TranslationsBloc>(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TranslationBloc, TranslationState>(
      listener: (context, state) {
        if (state is TranslationLoaded && state.saveSuccess == true) {
          _textController.text = '';
        }
      },
      child: Container(
        color: Colors.white,
        child: TextField(
          controller: _textController,
          autocorrect: false,
          textInputAction: TextInputAction.search,
          onChanged: (text) {
            if (text.length > 1) {
              _translationsBloc.add(TranslationsSearch(text));
            } else if (text.length == 0) {
              _translationsBloc.add(TranslationsRequest());
            }
          },
          onSubmitted: (String value) {
            if (value.length > 1) {
              Navigator.pushNamed(
                context,
                SearchNavigatorRoutes.translation_view,
                arguments: value,
              );
            }
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            suffixIcon: GestureDetector(
              child: Container(
                color: Color.fromRGBO(255, 255, 255, 0),
                child: Icon(Icons.clear),
              ),
              onTap: () {
                if (_textController.text != '') {
                  _textController.text = '';
                  _translationsBloc.add(TranslationsRequest());
                }
              },
            ),
            hintText: 'Search word',
            contentPadding: EdgeInsets.only(top: 15),
          ),
        ),
      ),
    );
  }
}
