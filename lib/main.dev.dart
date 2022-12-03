import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import './firebase_options.dart';
import './controllers/translation.dart';
import './controllers/parsing_schemas.dart';
import './blocs/observer.dart';
import './screens/search/bloc/search_cubit.dart';
import './screens/translation_view/bloc/translation_view_cubit.dart';
import './screens/settings/bloc/settings_cubit.dart';
import './widgets/pronunciation.dart';
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
  translateControllerInit();

  // preload parsing schemas
  await preloadLocalParsingSchemas();
  // await getParsingSchema('current', forceUpdate: true);

  setGlobalAudioContext();

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

