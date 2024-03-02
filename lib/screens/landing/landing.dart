import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/controllers/language/language.dart' as languages_controller;
import 'package:lingua_flutter/controllers/session/session.dart' as session_controller;
import 'package:lingua_flutter/widgets/typography/typography.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/widgets/language_selector/language_selector.dart';
import 'package:lingua_flutter/screens/router.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';
import 'package:lingua_flutter/styles/styles.dart';

@RoutePage()
class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Map<String, String>? _languages;
  bool _loading = true;
  SharedPreferences? _prefs;
  Language? _translateFrom;
  Language? _translateTo;
  late SettingsCubit _settingsCubit;

  @override
  void initState() {
    super.initState();
    _settingsCubit = context.read<SettingsCubit>();
    _retrievePreference();
  }

  void _retrievePreference() async {
    _prefs = await SharedPreferences.getInstance();
    if (!_checkLanguages()) {
      _retrieveLanguages();
    }
  }

  bool _checkLanguages() {
    if (_prefs != null) {
      final String? translateFrom = _prefs!.getString('translateFrom');
      final String? translateTo = _prefs!.getString('translateTo');

      if (translateFrom != null && translateTo != null) {
        AutoRouter.of(context).replaceNamed(Routes.home);
        return true;
      }
    }

    return false;
  }

  Future<void> _retrieveLanguages() async {
    if (_languages == null) {
      final storedLanguages = await languages_controller.get();
      if (storedLanguages != null) {
        setState(() {
          _languages = storedLanguages;
          _loading = false;
        });
      }
    }
  }

  void _checkBothLanguagesAreChosen() async {
    if (_translateFrom != null && _translateTo != null) {
      setState(() {
        _loading = true;
      });
      await session_controller.get(); // retrieve initial session
      _settingsCubit.setTranslateFrom(_translateFrom!);
      _settingsCubit.setTranslateTo(_translateTo!);
      if (mounted) {
        AutoRouter.of(context).pushNamed(Routes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    final isInDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isInDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isInDarkMode ? Brightness.dark : Brightness.light,
        ),
        elevation: 0,
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          if (!_loading)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Image(
                image: AssetImage('assets/images/logo.png'),
                width: 150,
                height: 150,
              ),
            ),

          if (!_loading)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Column(
                children: [
                  TypographyText(
                    text: 'Welcome! Translate words in a variety of languages with ease and connect them to images',
                    margin: EdgeInsets.only(bottom: 20),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    align: TextAlign.center,
                  ),
                ],
              ),
            ),

          if (!_loading)
            Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 40,
              ),
              constraints: const BoxConstraints(
                maxWidth: 300,
              ),
              child: LanguageSelectorItem(
                title: 'Translate from',
                titleStyle: const TextStyle(fontWeight: FontWeight.bold),
                languages: _languages,
                language: _translateFrom,
                size: LanguageSelectorSize.large,
                onChanged: (Language language) {
                  setState(() {
                    _translateFrom = language;
                  });
                  _checkBothLanguagesAreChosen();
                },
              ),
            ),

          if (!_loading)
            Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 110,
              ),
              constraints: const BoxConstraints(
                maxWidth: 300,
              ),
              child: LanguageSelectorItem(
                title: 'Translate to',
                titleStyle: const TextStyle(fontWeight: FontWeight.bold),
                languages: _languages,
                language: _translateTo,
                size: LanguageSelectorSize.large,
                onChanged: (Language language) {
                  setState(() {
                    _translateTo = language;
                  });
                  _checkBothLanguagesAreChosen();
                },
              ),
            ),
        ],
      ),
    );
  }
}
