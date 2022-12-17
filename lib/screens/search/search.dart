import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/utils/connectivity.dart';

import './bloc/search_cubit.dart';
import './bloc/search_state.dart';
import './widgets/search_field/search_field.dart';
import './widgets/search_list/search_list.dart';
import './widgets/quick_search/quick_search.dart';
import './widgets/empty_dictionary/empty_dictionary.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool _hasInternetConnection = false;

  @override
  void initState() {
    super.initState();
    _getInternetConnectionStatus();
    subscribeToNetworkChange('search', (bool result) {
      _hasInternetConnection = result;
    });
    context.read<SearchCubit>().fetchTranslations();
  }

  @override
  void dispose() {
    unsubscribeFromNetworkChange('search');

    super.dispose();
  }

  void _getInternetConnectionStatus() async {
    bool connection = await isInternetConnected();
    setState(() {
      _hasInternetConnection = connection;
    });
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
            return Column(
              children: [
                SearchField(hasInternetConnection: _hasInternetConnection),
                Expanded(
                  child: _buildResultsBody(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
