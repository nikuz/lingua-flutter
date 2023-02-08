import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lingua_flutter/screens/search/bloc/search_cubit.dart';
import 'package:lingua_flutter/screens/search/bloc/search_state.dart';
import 'package:lingua_flutter/app_config.dart' as config;

const prefName = 'askToRateUs';

class RatingListener extends StatefulWidget {
  const RatingListener({Key? key}) : super(key: key);

  @override
  State<RatingListener> createState() => _RatingListenerState();
}

class _RatingListenerState extends State<RatingListener> {
  final InAppReview _inAppReview = InAppReview.instance;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _retrievePreference();
  }

  void _retrievePreference() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _showRateUsRequest() async {
    if (_prefs != null && _prefs!.getBool(prefName) != true) {
      _prefs!.setBool(prefName, true);
      if (await _inAppReview.isAvailable()) {
        _inAppReview.requestReview();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchCubit, SearchState>(
      listener: (context, state) async {
        // request review only once when amount of saved words exceeded the threshold set in config.wordsAmountRateThreshold
        if (state.totalAmount > config.wordsAmountRateThreshold) {
          _showRateUsRequest();
        }
      },
      child: Container(),
    );
  }
}