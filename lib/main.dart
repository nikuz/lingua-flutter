import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './controllers/dictionary/dictionary.dart' as dictionary_controller;
import 'controllers/parsing_schema/parsing_schema.dart' as parsing_schema_controller;
import 'controllers/language/language.dart' as languages_controller;
import 'controllers/audio/audio.dart';
import 'controllers/error_logger/error_logger.dart';
import './app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initiateErrorLogger();

  // initiate controllers
  dictionary_controller.init();

  // preload parsing schemas and languages
  await parsing_schema_controller.preload();
  await languages_controller.preload();

  setGlobalAudioContext();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(App(prefs));
}

