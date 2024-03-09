import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/controllers/connectivity/connectivity.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/regexp.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';
import 'package:lingua_flutter/models/quick_translation/quick_translation.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/screens/router.gr.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_state.dart';
import 'package:lingua_flutter/widgets/snack_bar/snack_bar.dart';

import './bloc/search_cubit.dart';
import './bloc/search_state.dart';
import './widgets/search_field/search_field.dart';
import './widgets/search_list/search_list.dart';
import './widgets/quick_search/quick_search.dart';
import './widgets/empty_dictionary/empty_dictionary.dart';
import './widgets/empty_search/empty_search.dart';
import './widgets/error/search_error.dart';
import './widgets/url_translation/url_translation.dart';
import './search_state.dart';
import './search_constants.dart';

@RoutePage()
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with WidgetsBindingObserver {
  final Map<String, Function> _scrollListeners = {};
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late SearchCubit _searchCubit;
  late SettingsCubit _settingsCubit;
  bool _hasInternetConnection = false;
  late Language _translateFrom;
  late Language _translateTo;
  late int? _backupRestoreAt;

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
    _translateFrom = _settingsCubit.state.translateFrom;
    _translateTo = _settingsCubit.state.translateTo;
    _backupRestoreAt = _settingsCubit.state.backupRestoreAt;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getInternetConnectionStatus();
    } else {
      CustomSnackBar.dismiss(context);
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

  void _unfocusSearchField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.unfocus();
    });
  }

  void _updateList() {
    _textController.clear();
    _searchCubit.fetchTranslations(searchText: null);
  }

  void _resetLanguages() {
    _translateFrom = _settingsCubit.state.translateFrom;
    _translateTo = _settingsCubit.state.translateTo;
  }

  void _submitHandler(String word, {
    required Language translateFrom,
    required Language translateTo,
    QuickTranslation? quickTranslation,
  }) async {
    final sanitizedWord = removeQuotesFromString(removeSlashFromString(word)).trim();
    if (sanitizedWord.isNotEmpty && !_searchTextIsUrl(sanitizedWord)) {
      _unfocusSearchField();
      final result = await AutoRouter.of(context).push<TranslationContainer>(
        TranslationViewRoute(
          word: sanitizedWord,
          translateFrom: translateFrom,
          translateTo: translateTo,
          quickTranslation: quickTranslation,
        ),
      );
      if (result != null) {
        if (_searchCubit.state.translations.any((item) => item.id == result.id)) {
          _searchCubit.updateTranslation(result);
        } else {
          _updateList();
        }
        _resetLanguages();
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

  bool _searchTextIsUrl(String? searchText) =>
      (searchText != null && (uriStartReg.hasMatch(searchText) || uriReg.hasMatch(searchText)));

  Widget _buildResultsBody(BuildContext context, SearchState state) {
    final MyTheme theme = Styles.theme(context);
    if (
      state.translations.isEmpty
      && state.searchText?.isEmpty != false // show progress indicator only on first results load
      && state.loading
    ) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colors.focus,
        ),
      );
    }

    if (state.error != null) {
      return const SearchError();
    }

    if (_searchTextIsUrl(state.searchText)) {
      return const UrlTranslation();
    }

    if (
      state.translations.isEmpty
      && _hasInternetConnection
      && state.searchText?.isNotEmpty == true
    ) {
      return QuickSearch(
        searchText: state.searchText!,
        translateFrom: _translateFrom,
        translateTo: _translateTo,
        onTranslateFromChange: (language) {
          setState(() {
            _translateFrom = language;
          });
        },
        onTranslateToChange: (language) {
          setState(() {
            _translateTo = language;
          });
        },
        onLanguageSourceSwap: (from, to) {
          setState(() {
            _translateFrom = from;
            _translateTo = to;
          });
        },
        onDispose: _resetLanguages,
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
    final isInDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: theme.colors.background,
        appBar: AppBar(
          backgroundColor: theme.colors.background.withOpacity(0.8),
          elevation: 0,
          toolbarHeight: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isInDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness: isInDarkMode ? Brightness.dark : Brightness.light,
          ),
        ),
        body: BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state.translateFrom != _translateFrom
                || state.translateTo != _translateTo
                || state.backupRestoreAt != _backupRestoreAt
            ) {
              // refresh search list after restore from backup
              if (state.backupRestoreAt != _backupRestoreAt) {
                Future.delayed(const Duration(seconds: 1), _updateList);
              }
              setState(() {
                _translateFrom = state.translateFrom;
                _translateTo = state.translateTo;
                _backupRestoreAt = state.backupRestoreAt;
              });
            }
          },
          child: BlocBuilder<SearchCubit, SearchState>(
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
                      _buildResultsBody(context, state),
                      SearchField(
                        translateFrom: _translateFrom,
                        translateTo: _translateTo,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
