import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/utils/sizes.dart';
import 'package:lingua_flutter/utils/connectivity.dart';
import 'package:lingua_flutter/screens/search/router.dart';
import 'package:lingua_flutter/screens/search/translation_view/bloc/bloc.dart';
import 'package:lingua_flutter/screens/search/translation_view/bloc/state.dart';
import 'package:lingua_flutter/screens/search/translation_view/bloc/events.dart';

import 'bloc/bloc.dart';
import 'bloc/events.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _textController = TextEditingController();
  TranslationsBloc _translationsBloc;
  bool _hasInternetConnection = false;
  var _networkChangeSubscription;

  @override
  void initState() {
    super.initState();
    _translationsBloc = BlocProvider.of<TranslationsBloc>(context);
    _getInternetConnectionStatus();
    _networkChangeSubscription = subscribeToNetworkChange((bool result) {
      _hasInternetConnection = result;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _networkChangeSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TranslationBloc, TranslationState>(
      listener: (context, state) {
        if (state is TranslationLoaded && state.saveSuccess == true) {
          _textController.text = '';
        }
      },
      child: Container(
        color: Colors.white,
        child: TextField(
          controller: _textController,
          autocorrect: false,
          textInputAction: _hasInternetConnection ? TextInputAction.search : TextInputAction.done,
          onChanged: (text) {
            if (text.length > 1) {
              _translationsBloc.add(TranslationsSearch(text));
            } else if (text.length == 0) {
              _translationsBloc.add(TranslationsRequest());
            }
          },
          onSubmitted: (String value) {
            if (_hasInternetConnection && value.length > 1) {
              BlocProvider.of<TranslationBloc>(context).add(TranslationClear());
              Navigator.pushNamed(
                context,
                SearchNavigatorRoutes.translation_view,
                arguments: value,
              );
            }
          },
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: EdgeInsets.only(
                left: SizeUtil.vmax(5),
                right: SizeUtil.vmax(5),
              ),
              child: Icon(
                Icons.search,
                size: SizeUtil.vmax(25),
              )
            ),
            suffixIcon: GestureDetector(
              child: Container(
                color: Color.fromRGBO(255, 255, 255, 0),
                child: Icon(
                  Icons.clear,
                  size: SizeUtil.vmax(25),
                ),
              ),
              onTap: () {
                if (_textController.text != '') {
                  _textController.text = '';
                  _translationsBloc.add(TranslationsRequest());
                }
              },
            ),
            hintText: 'Search word',
            hintStyle: TextStyle(
              fontSize: SizeUtil.vmax(20),
            ),
          ),
          style: TextStyle(
            fontSize: SizeUtil.vmax(20),
            color: Colors.black
          ),
        ),
      ),
    );
  }

  void _getInternetConnectionStatus() async {
    bool connection = await isInternetConnected();
    setState(() {
      _hasInternetConnection = connection;
    });
  }
}
