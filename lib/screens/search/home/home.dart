import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/app_config.dart' as appConfig;

import 'translations_list.dart';
import 'bloc/events.dart';
import 'bloc/bloc.dart';
import 'search.dart';

class SearchHomePage extends StatefulWidget {
  @override
  _SearchHomePageState createState() => _SearchHomePageState();
}

class _SearchHomePageState extends State<SearchHomePage> {
  bool apiUrlDownloaded = false;

  @override
  void initState() {
    super.initState();
    if (kReleaseMode) {
      _getApiUrl();
    } else {
      _loadData(appConfig.getApiDebugUrl());
    }
  }

  _getApiUrl() async {
    final response = await http.get(appConfig.apiGetterUrl);
    if (response.statusCode == 200) {
      _loadData(response.body);
    } else {
      throw Exception('Can\'t get API url');
    }
  }

  _loadData(String apiUrl) {
    appConfig.apiUrl = apiUrl;
    setState(() {
      apiUrlDownloaded = true;
    });
    BlocProvider.of<TranslationsBloc>(context).add(TranslationsRequest());
  }

  @override
  Widget build(BuildContext context) {
    Widget list = Center(
      child: CircularProgressIndicator(),
    );

    if (apiUrlDownloaded == true) {
      list = TranslationsList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Lingua'),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Search(),
            Expanded(
              child: list,
            ),
          ],
        ),
      ),
    );
  }
}
