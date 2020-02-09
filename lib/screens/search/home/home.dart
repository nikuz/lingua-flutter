import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'translations_list.dart';
import 'bloc/events.dart';
import 'bloc/bloc.dart';
import 'search.dart';

class SearchHomePage extends StatefulWidget {
  @override
  _SearchHomePageState createState() => _SearchHomePageState();
}

class _SearchHomePageState extends State<SearchHomePage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TranslationsBloc>(context).add(TranslationsRequest());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Search'),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Search(),
            Expanded(
              child: TranslationsList(),
            ),
          ],
        ),
      ),
    );
  }
}
