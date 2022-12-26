import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import './firebase_options.dart';
import './controllers/local_translation.dart' as local_translate_controller;
import './controllers/parsing_schemas.dart' as parsing_schemas_controller;
import './controllers/languages.dart' as languages_controller;
import './providers/audio.dart';
import './providers/error_logger.dart';
import './blocs/observer.dart';
// import './utils/files.dart';
import './app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Crashlytics
  initiateErrorLogger();

  Bloc.observer = MyBlocObserver();

  // initiate controllers
  local_translate_controller.init();

  // preload parsing schemas and languages
  await parsing_schemas_controller.preload();
  // await parsing_schemas_controller.get('current');
  await languages_controller.preload();
  // await languages_controller.get(forceUpdate: true);

  setGlobalAudioContext();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // final dir = await getDocumentsPath();
  // print(dir);

  runApp(App(prefs));
}

