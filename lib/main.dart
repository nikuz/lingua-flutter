import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import './firebase_options.dart';
import './controllers/parsing_schemas.dart';
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
  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  Bloc.observer = MyBlocObserver();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // preload parsing schemas
  await preloadLocalParsingSchemas();

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
      child: App(),
    ),
  );
}

