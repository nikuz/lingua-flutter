import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import './firebase_options.dart';
import './controllers/local_translation.dart' as local_translate_controller;
import './controllers/parsing_schemas.dart' as parsing_schemas_controller;
import './controllers/languages.dart' as languages_controller;
import './controllers/audio.dart' as audio_controller;
import './app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // initiate controllers
  local_translate_controller.init();

  // preload parsing schemas and languages
  await parsing_schemas_controller.preload();
  await languages_controller.preload();

  audio_controller.setGlobalAudioContext();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(App(prefs));
}

