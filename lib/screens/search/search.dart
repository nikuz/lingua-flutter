import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/providers/connectivity.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/screens/router.gr.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';

import './bloc/search_cubit.dart';
import './bloc/search_state.dart';
import './widgets/search_field/search_field.dart';
import './widgets/search_list/search_list.dart';
import './widgets/quick_search/quick_search.dart';
import './widgets/empty_dictionary/empty_dictionary.dart';
import './widgets/empty_search/empty_search.dart';
import './widgets/error/search_error.dart';
import './search_state.dart';
import './search_constants.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with WidgetsBindingObserver {
  final Map<String, Function> _scrollListeners = {};
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late SearchCubit _searchCubit;
  late SettingsCubit _settingsCubit;
  bool _hasInternetConnection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchCubit = context.read<SearchCubit>();
    _settingsCubit = context.read<SettingsCubit>();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _getInternetConnectionStatus();
    subscribeToNetworkChange('search', (bool isConnected) {
      setState(() {
        _hasInternetConnection = isConnected;
      });
    });
    context.read<SearchCubit>().fetchTranslations();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getInternetConnectionStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unsubscribeFromNetworkChange('search');
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _getInternetConnectionStatus() async {
    bool connection = await isInternetConnected();
    setState(() {
      _hasInternetConnection = connection;
    });
  }

  double _getPaddingTop() {
    final topPadding = MediaQuery.of(context).padding.top;
    return SearchConstants.searchFieldHeight + topPadding;
  }

  void _submitHandler(String word, {
    TranslationContainer? quickTranslation,
    Language? translateFrom,
    Language? translateTo
  }) async {
    final sanitizedWord = removeQuotesFromString(removeSlashFromString(word)).trim();
    if (sanitizedWord.isNotEmpty) {
      if (!_settingsCubit.state.languageSourcesAreSet) {
        _settingsCubit.setLanguageSourcesAreSet();
      }
      final result = await AutoRouter.of(context).push<TranslationContainer>(
        TranslationViewRoute(
          word: sanitizedWord,
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focusNode.unfocus();
          });
          _searchCubit.fetchTranslations(searchText: null);
        }
      }
    }
  }

  void _subscribeToListScroll(String name, Function callback) {
    _scrollListeners[name] = callback;
  }

  void _unsubscribeFromListScroll(String name) {
    _scrollListeners.remove(name);
  }

  void _broadcastListScroll(ScrollNotification notification) {
    _scrollListeners.forEach((String key, Function listener) {
      listener(notification);
    });
  }

  Widget _buildResultsBody(SearchState state) {
    if (
      state.translations.isEmpty
      && state.searchText?.isEmpty != false // show progress indicator only on first results load
      && state.loading
    ) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return const SearchError();
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
    final MyTheme theme = Styles.theme(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.colors.background.withOpacity(0.8),
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return SafeArea(
            top: false,
            child: SearchInheritedState(
              textController: _textController,
              focusNode: _focusNode,
              hasInternetConnection: _hasInternetConnection,
              submitHandler: _submitHandler,
              subscribeToListScroll: _subscribeToListScroll,
              unsubscribeFromListScroll: _unsubscribeFromListScroll,
              broadcastListScroll: _broadcastListScroll,
              getPaddingTop: _getPaddingTop,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildResultsBody(state),
                  const SearchField(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
