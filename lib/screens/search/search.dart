import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/providers/connectivity.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import './bloc/search_cubit.dart';
import './bloc/search_state.dart';
import './widgets/search_field/search_field.dart';
import './widgets/search_list/search_list.dart';
import './widgets/quick_search/quick_search.dart';
import './widgets/empty_dictionary/empty_dictionary.dart';
import './widgets/empty_search/empty_search.dart';
import './search_state.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late TextEditingController _textController;
  late SearchCubit _searchCubit;
  bool _hasInternetConnection = false;

  @override
  void initState() {
    super.initState();
    _searchCubit = context.read<SearchCubit>();
    _textController = TextEditingController();
    _getInternetConnectionStatus();
    subscribeToNetworkChange('search', (bool isConnected) {
      setState(() {
        _hasInternetConnection = isConnected;
      });
    });
    context.read<SearchCubit>().fetchTranslations();
  }

  @override
  void dispose() {
    unsubscribeFromNetworkChange('search');
    _textController.dispose();
    super.dispose();
  }

  void _getInternetConnectionStatus() async {
    bool connection = await isInternetConnected();
    setState(() {
      _hasInternetConnection = connection;
    });
  }

  void _submitHandler(String word, {
    TranslationContainer? quickTranslation,
    Language? translateFrom,
    Language? translateTo
  }) async {
    if (word.isNotEmpty) {
      final result = await AutoRouter.of(context).push<TranslationContainer>(
        TranslationViewRoute(
          word: word,
          quickTranslation: quickTranslation,
          translateFrom: translateFrom,
          translateTo: translateTo,
        ),
      );
      if (result != null) {
        if (_searchCubit.state.translations.any((item) => item.id == result.id)) {
          _searchCubit.updateTranslation(result);
        } else {
          _textController.clear();
          _searchCubit.fetchTranslations(searchText: null);
        }
      }
    }
  }

  Widget _buildResultsBody(SearchState state) {
    if (state.error?.message != null) {
      return Center(
        child: Text(state.error!.message),
      );
    }

    if (
      state.translations.isEmpty
      && state.searchText?.isEmpty != false // show progress indicator only on first results load
      && state.loading
    ) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (
      state.translations.isEmpty
      && _hasInternetConnection
      && state.searchText?.isNotEmpty == true
    ) {
      return QuickSearch(
        searchText: state.searchText!,
      );
    }

    if (
      state.translations.isEmpty
      && !_hasInternetConnection
      && state.searchText?.isNotEmpty == true
    ) {
      return EmptySearch(hasInternetConnection: _hasInternetConnection);
    }

    if (state.translations.isEmpty && !state.loading) {
      return const EmptyDictionary();
    }

    if (state.translations.isNotEmpty && !state.loading) {
      return const SearchList();
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Dictionary',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return SearchInheritedState(
              textController: _textController,
              hasInternetConnection: _hasInternetConnection,
              submitHandler: _submitHandler,
              child: Column(
                children: [
                  const SearchField(),
                  Expanded(
                    child: _buildResultsBody(state),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
