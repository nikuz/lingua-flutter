import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/utils/connectivity.dart';
import 'package:lingua_flutter/screens/translation_view/bloc/translation_view_cubit.dart';
import 'package:lingua_flutter/screens/translation_view/bloc/translation_view_state.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../bloc/search_cubit.dart';

class SearchField extends StatefulWidget {
  SearchField({Key? key}) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _textController = TextEditingController();
  late SearchCubit _searchCubit;
  bool _hasInternetConnection = false;

  @override
  void initState() {
    super.initState();
    _searchCubit = context.read<SearchCubit>();
    _getInternetConnectionStatus();
    subscribeToNetworkChange('search', (bool result) {
      _hasInternetConnection = result;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    unsubscribeFromNetworkChange('search');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TranslationViewCubit, TranslationViewState>(
      listener: (context, state) {
        if (state.savedTranslation != null) {
          _textController.text = '';
        }
      },
      child: Container(
        child: TextField(
          controller: _textController,
          autocorrect: false,
          textInputAction: _hasInternetConnection ? TextInputAction.search : TextInputAction.done,
          onChanged: (text) {
            _searchCubit.fetchTranslations(searchText: text.length > 1 ? text : null);
          },
          onSubmitted: (String value) {
            if (_hasInternetConnection && value.length > 1) {
              AutoRouter.of(context).push(TranslationViewRoute(word: value));
            }
          },
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: EdgeInsets.only(
                left: 5,
                right: 5,
              ),
              child: Icon(
                Icons.search,
                size: 25,
              )
            ),
            suffixIcon: GestureDetector(
              child: Container(
                child: Icon(
                  Icons.clear,
                  size: 25,
                ),
              ),
              onTap: () {
                if (_textController.text != '') {
                  _textController.text = '';
                  _searchCubit.fetchTranslations();
                }
              },
            ),
            hintText: 'Search word',
            hintStyle: TextStyle(
              fontSize: 20,
            ),
          ),
          style: TextStyle(
            fontSize: 20,
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
