import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import './firebase_options.dart';
import './controllers/local_translation.dart' as local_translate_controller;
import './controllers/parsing_schemas.dart' as parsing_schemas_controller;
import './controllers/languages.dart' as languages_controller;
import './controllers/audio.dart' as audio_controller;
import './blocs/observer.dart';
import './screens/search/bloc/search_cubit.dart';
import './screens/translation_view/bloc/translation_view_cubit.dart';
import './screens/settings/bloc/settings_cubit.dart';
import './app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Bloc.observer = MyBlocObserver();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // initiate controllers
  local_translate_controller.init();

  // preload parsing schemas and languages
  await parsing_schemas_controller.preload();
  // await parsing_schemas_controller.get('current');
  await languages_controller.preload();

  audio_controller.setGlobalAudioContext();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(),
        ),
        BlocProvider<TranslationViewCubit>(
          create: (context) => TranslationViewCubit(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(prefs),
        ),
      ],
      child: const App(),
    ),
  );
}

