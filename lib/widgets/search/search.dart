import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/widgets/translations_list/bloc/bloc.dart';
import 'package:lingua_flutter/widgets/translations_list/bloc/events.dart';

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
    return TextField(
      controller: _textController,
      autocorrect: false,
      onChanged: (text) {
        if (text.length > 1) {
          _translationsBloc.add(TranslationsSearch(text));
        }
      },
      onEditingComplete: () {
        if (_textController.text.length > 1) {
          Navigator.pushNamed(
            context,
            '/translation-view',
            arguments: { 'word': _textController.text },
          );
        }
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon: GestureDetector(
          child: Icon(Icons.clear),
          onTap: () {
            if (_textController.text != '') {
              _textController.text = '';
              _translationsBloc.add(TranslationsRequest());
            }
          },
        ),
        hintText: 'Search word',
      ),
    );
  }
}
