import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/widgets/translation_word_view/translation_word_view.dart';
import 'package:lingua_flutter/widgets/language_selector/language_selector.dart';
import 'package:lingua_flutter/widgets/button/button.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/providers/api.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';
import '../../search_state.dart';
import './constants.dart';

class QuickSearch extends StatefulWidget {
  final String searchText;
  final Language translateFrom;
  final Language translateTo;
  final void Function(Language translateFrom) onTranslateFromChange;
  final void Function(Language translateTo) onTranslateToChange;
  final void Function(Language translateFrom, Language translateTo) onLanguageSourceSwap;

  const QuickSearch({
    super.key,
    required this.searchText,
    required this.translateFrom,
    required this.translateTo,
    required this.onTranslateFromChange,
    required this.onTranslateToChange,
    required this.onLanguageSourceSwap,
  });

  @override
  State<QuickSearch> createState() => _QuickSearchState();
}

class _QuickSearchState extends State<QuickSearch> {
  late SearchCubit _searchCubit;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _searchCubit = context.read<SearchCubit>();
    _request();
  }

  @override
  void didUpdateWidget(covariant QuickSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchText != widget.searchText
        || oldWidget.translateFrom != widget.translateFrom
        || oldWidget.translateTo != widget.translateTo
    ) {
      _request();
    }
  }

  @override
  void dispose() {
    _searchCubit.clearQuickTranslation();
    _cancelToken?.cancel();
    super.dispose();
  }

  void _request() {
    if (_cancelToken?.isCancelled == false) {
      _cancelToken?.cancel();
    }
    _cancelToken = CancelToken();
    _searchCubit.quickTranslation(
      word: widget.searchText,
      translateFrom: widget.translateFrom,
      translateTo: widget.translateTo,
      cancelToken: _cancelToken,
    );
  }

  Widget _buildContentBody(SearchState state) {
    if (state.quickTranslationError != null) {
      return const SizedBox(
        height: QuickSearchConstants.minHeight - 20,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text('Can\'t translate at the moment. Please try again later.'),
            ),
          ),
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
                shape: ButtonShape.oval,
                icon: Icons.arrow_forward,
                onPressed: () {
                  final text = searchState?.textController.text;
                  if (searchState?.hasInternetConnection == true && text != null) {
                    final sanitizedWord = removeQuotesFromString(removeSlashFromString(text)).trim();
                    TranslationContainer? quickTranslation;

                    if (sanitizedWord == state.quickTranslation?.word
                        && widget.translateFrom == state.quickTranslation?.translateFrom
                        && widget.translateTo == state.quickTranslation?.translateTo
                    ) {
                      quickTranslation = state.quickTranslation;
                    }

                    if (sanitizedWord.isNotEmpty) {
                      searchState?.submitHandler(
                        sanitizedWord,
                        translateFrom: widget.translateFrom,
                        translateTo: widget.translateTo,
                        quickTranslation: quickTranslation,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),

        LanguageSelector(
          selectorFromTitle: 'Translate from',
          from: widget.translateFrom,
          selectorToTitle: 'Translate to',
          to: widget.translateTo,
          onFromChanged: (language) {
            widget.onTranslateFromChange(language);
          },
          onSwapped: (from, to) {
            widget.onLanguageSourceSwap(from, to);
          },
          onToChanged: (language) {
            widget.onTranslateToChange(language);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = SearchInheritedState.of(context);

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.only(
            top: searchState?.getPaddingTop() ?? 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  constraints: const BoxConstraints(
                    minHeight: QuickSearchConstants.minHeight,
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
          ),
        );
      },
    );
  }
}
