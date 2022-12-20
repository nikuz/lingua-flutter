import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/widgets/translation_word_view/translation_word_view.dart';
import 'package:lingua_flutter/widgets/language_selector/language_selector.dart';
import 'package:lingua_flutter/widgets/button/button.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_state.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';
import '../../search_state.dart';
import './constants.dart';

class QuickSearch extends StatefulWidget {
  final String searchText;

  const QuickSearch({
    Key? key,
    required this.searchText,
  }) : super(key: key);

  @override
  State<QuickSearch> createState() => _QuickSearchState();
}

class _QuickSearchState extends State<QuickSearch> {
  late SearchCubit _searchCubit;
  Timer? _debounce;
  late Language _originalTranslateFrom;
  late Language _originalTranslateTo;
  late Language _translateFrom;
  late Language _translateTo;

  @override
  void initState() {
    super.initState();
    _searchCubit = context.read<SearchCubit>();
    final settingsState = context.read<SettingsCubit>().state;
    _originalTranslateFrom = settingsState.translateFrom;
    _translateFrom = settingsState.translateFrom;
    _originalTranslateTo = settingsState.translateTo;
    _translateTo = settingsState.translateTo;
    _debounceRequest();
  }

  @override
  void didUpdateWidget(covariant QuickSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchText != widget.searchText) {
      _debounceRequest();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCubit.clearQuickTranslation();
    super.dispose();
  }

  void _debounceRequest() {
    _debounce?.cancel();
    _debounce = Timer(QuickSearchConstants.debouncePeriod, () {
      _searchCubit.quickTranslation(
        word: widget.searchText,
        translateFrom: _translateFrom,
        translateTo: _translateTo,
      );
    });
  }

  Widget _buildContentBody(SearchState state) {
    if (state.quickTranslationError != null) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text('Can\'t translate at the moment. Please try again later.'),
        ),
      );
    }

    final searchState = SearchInheritedState.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 15,
          ),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    if (state.quickTranslation != null)
                      TranslationWordView(
                        translation: state.quickTranslation!,
                      ),

                    if (state.quickTranslationLoading || state.quickTranslation == null)
                      const Text('...'),
                  ],
                ),
              ),

              Button(
                width: 56,
                height: 56,
                outlined: false,
                elevated: true,
                shape: ButtonShape.circular,
                icon: Icons.arrow_forward,
                onPressed: () {
                  if (searchState?.hasInternetConnection == true) {
                    searchState?.submitHandler(
                      searchState.textController.text,
                      quickTranslation: state.quickTranslation,
                      translateFrom: _translateFrom,
                      translateTo: _translateTo,
                    );
                  }
                },
              ),
            ],
          ),
        ),

        BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state.translateFrom != _originalTranslateFrom || state.translateTo != _originalTranslateTo) {
              setState(() {
                _translateFrom = state.translateFrom;
                _translateTo = state.translateTo;
              });
              _debounceRequest();
            }
          },
          child: LanguageSelector(
            from: _translateFrom,
            to: _translateTo,
            onFromChanged: (language) {
              setState(() {
                _translateFrom = language;
              });
              _debounceRequest();
            },
            onSwapped: (from, to) {
              setState(() {
                _translateFrom = from;
                _translateTo = to;
              });
              _debounceRequest();
            },
            onToChanged: (language) {
              setState(() {
                _translateTo = language;
              });
              _debounceRequest();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                constraints: const BoxConstraints(
                  minHeight: 75,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildContentBody(state),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
