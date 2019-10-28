import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/app_config.dart' as appConfig;

import 'package:lingua_flutter/widgets/translations/translations.dart';
import 'package:lingua_flutter/widgets/translations/bloc/events.dart';
import 'package:lingua_flutter/widgets/translations/bloc/bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool apiUrlDownloaded = false;

  @override
  void initState() {
    super.initState();
    if (kReleaseMode) {
      _getApiUrl();
    } else {
      _loadData(appConfig.apiDebugUrl);
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
    if (!apiUrlDownloaded) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return TranslationsList();
  }
}
