import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/widgets/button/button.dart';
import 'package:lingua_flutter/widgets/language_selector/language_selector.dart';
import 'package:lingua_flutter/screens/router.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
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
    _checkLanguages();
  }

  void _checkLanguages() {
    if (_prefs != null) {
      final String? translateFrom = _prefs!.getString('translateFrom');
      final String? translateTo = _prefs!.getString('translateTo');

      if (translateFrom != null && translateTo != null) {
        AutoRouter.of(context).replaceNamed(Routes.home);
      } else {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_loading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (!_loading)
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Text(
                  'Please select source and target languages. You always can change them later \nin Settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),

            if (!_loading)
              LanguageSelector(
                fromTitle: 'Translate from',
                from: _translateFrom,
                toTitle: 'Translate to',
                to: _translateTo,
                size: LanguageSelectorSize.large,
                onFromChanged: (language) {
                  setState(() {
                    _translateFrom = language;
                  });
                },
                onSwapped: (from, to) {
                  setState(() {
                    _translateFrom = from;
                    _translateTo = to;
                  });
                },
                onToChanged: (language) {
                  setState(() {
                    _translateTo = language;
                  });
                },
              ),

            if (!_loading)
              ButtonBlue(
                text: 'Next',
                size: ButtonSize.large,
                width: 100.0,
                height: 60.0,
                margin: const EdgeInsets.only(top: 40),
                disabled: _translateFrom == null || _translateTo == null,
                onPressed: () {
                  if (_translateFrom != null) {
                    _settingsCubit.setTranslateFrom(_translateFrom!);
                  }
                  if (_translateTo != null) {
                    _settingsCubit.setTranslateTo(_translateTo!);
                  }
                  AutoRouter.of(context).pushNamed(Routes.home);
                },
              ),
          ],
        ),
      ),
    );
  }
}
