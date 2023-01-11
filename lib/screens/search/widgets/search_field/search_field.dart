import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/text_field/text_field.dart';
import 'package:lingua_flutter/utils/remap_value.dart';
import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/models/translation.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';
import '../../search_state.dart';
import '../../search_constants.dart';

class SearchField extends StatefulWidget {
  final Language translateFrom;
  final Language translateTo;

  const SearchField({
    super.key,
    required this.translateFrom,
    required this.translateTo,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  SearchInheritedState? searchState;
  final String _scrollSubscriptionName = 'search-field';
  bool _isAnimated = false;
  bool _isFloat = false;
  double? _position;
  double? _defaultPosition;
  double? _scrollStartPosition;
  double _opacity = 1;
  int _listLength = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final topPadding = MediaQuery.of(context).padding.top;

    if (_defaultPosition == null || topPadding != _defaultPosition) {
      setState(() {
        _position = _position != null && _position! < 0 ? _position : topPadding;
        _defaultPosition = topPadding;
        _opacity = 1;
      });
    }

    searchState = SearchInheritedState.of(context);
    searchState?.unsubscribeFromListScroll(_scrollSubscriptionName);
    searchState?.subscribeToListScroll(_scrollSubscriptionName, _onListScroll);
  }

  @override
  void dispose() {
    searchState?.unsubscribeFromListScroll(_scrollSubscriptionName);
    super.dispose();
  }

  void _onListScroll(ScrollNotification notification) {
    final pixels = notification.metrics.pixels;
    bool isFloat = _isFloat;
    double? scrollStartPosition = _scrollStartPosition;
    final defaultPosition = _defaultPosition ?? 0;
    double position = _position ?? 0;
    bool isAnimated = _isAnimated;

    if (notification is ScrollStartNotification) {
      scrollStartPosition = pixels;
    }

    if (notification is ScrollUpdateNotification) {
      // reset "isFloat" value if scrolling position is back to the very top
      if (pixels <= 0 && isFloat) {
        isFloat = false;
      }

      // when scrolling position is less than the field height plus margin,
      // then the absolute scrolling position "pixels" value is more stable than "shift"
      if (!isFloat && pixels < defaultPosition + SearchConstants.searchFieldHeight) {
        position = defaultPosition - pixels;
        isAnimated = false;
      } else {
        // if the scrolling position is more than the field height plus margin,
        // then we use "shift" value to position the field
        final shift = pixels - (scrollStartPosition ?? 0);
        // if field is already floating and user scrolls down,
        // then we gradually hide the field

        if (isFloat && shift > 0) {
          position = defaultPosition - shift;
          isAnimated = false;
        } else if (shift < SearchConstants.searchFieldFloatingThreshold) {
          // but if field is floating, which is always true when user scrolls from bottom to top,
          // then we use defaultPosition
          position = defaultPosition;
          scrollStartPosition = pixels;
          // if field is not floating yet and user scrolled more than "searchFieldFloatingThreshold" pixels top,
          // then we show the floating field
          isFloat = true;
          isAnimated = true;
        } else if (!isFloat) {
          // on fast scroll "pixels" counter increases faster than widget can update
          // and "pixels < defaultPosition..." condition falls under the else term
          // but the field is not fully hidden yet and the scroll is still in progress
          // in such case we simply hide the field
          position = -SearchConstants.searchFieldHeight;
          isAnimated = true;
        }
      }
    }

    if (notification is ScrollEndNotification) {
      // if user stopped scrolling and the field is not fully hidden,
      // then hide it
      if (isFloat && position < defaultPosition) {
        position = -SearchConstants.searchFieldHeight;
        isFloat = false;
        isAnimated = true;
      }
    }

    if (position < 0 && searchState?.focusNode.hasFocus == true) {
        searchState?.focusNode.unfocus();
    }

    if (position >= defaultPosition) {
      position = defaultPosition;
    }

    // don't always update the state, check for changed values
    if (_position != position
        || _isAnimated != isAnimated
        || _isFloat != isFloat
        || _scrollStartPosition != scrollStartPosition
    ) {
      double opacity = remapValue(
        value: position,
        inMin: 0,
        inMax: defaultPosition,
        outMin: 0,
        outMax: 1,
      );
      if (defaultPosition == 0) {
        opacity = remapValue(
          value: position,
          inMin: -SearchConstants.searchFieldHeight,
          inMax: 0,
          outMin: 0,
          outMax: 1,
        );
      }
      setState(() {
        _position = position;
        _isAnimated = isAnimated;
        _isFloat = isFloat;
        _scrollStartPosition = scrollStartPosition;
        _opacity = opacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    final borderRadius = BorderRadius.circular(8);

    return BlocListener<SearchCubit, SearchState>(
      listener: (context, state) {
        final listIsShrinked = _listLength > state.translations.length;
        if (_listLength != state.translations.length) {
          setState(() {
            _listLength = state.translations.length;
            _position = listIsShrinked ? _defaultPosition : _position;
            _isAnimated = listIsShrinked ? true : _isAnimated;
            _opacity = listIsShrinked ? 1 : _opacity;
          });
        }
      },
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return AnimatedPositioned(
            top: _position,
            left: 0,
            right: 0,
            duration: _isAnimated ? SearchConstants.appearanceAnimationDuration : Duration.zero,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: SearchConstants.searchFieldHeight - 15,
                    color: theme.colors.background.withOpacity(0.8),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 15,
                    right: 15,
                  ),
                  child: Opacity(
                    opacity: _opacity,
                    child: CustomTextField(
                      controller: searchState?.textController,
                      focusNode: searchState?.focusNode,
                      textInputAction: searchState?.hasInternetConnection == true
                          ? TextInputAction.search
                          : TextInputAction.done,
                      hintText: 'Search for new words',
                      borderRadius: borderRadius,
                      backgroundColor: theme.colors.cardBackground,
                      elevation: 1,
                      maxLength: 100,
                      prefixIcon: Icons.search,
                      onChanged: (text) {
                        final sanitizedWord = removeQuotesFromString(removeSlashFromString(text)).trim();
                        final newSearchText = sanitizedWord.isNotEmpty ? sanitizedWord : null;
                        if (state.searchText != newSearchText) {
                          context.read<SearchCubit?>()?.fetchTranslations(searchText: newSearchText);
                        }
                      },
                      onSubmitted: (_) {
                        final text = searchState?.textController.text;
                        if (searchState?.hasInternetConnection == true && text != null) {
                          final sanitizedWord = removeQuotesFromString(removeSlashFromString(text)).trim();
                          if (sanitizedWord.isNotEmpty) {
                            TranslationContainer? quickTranslation;

                            if (sanitizedWord == state.quickTranslation?.word
                                && widget.translateFrom == state.quickTranslation?.translateFrom
                                && widget.translateTo == state.quickTranslation?.translateTo
                            ) {
                              quickTranslation = state.quickTranslation;
                            }

                            searchState?.submitHandler(
                              sanitizedWord,
                              translateFrom: widget.translateFrom,
                              translateTo: widget.translateTo,
                              quickTranslation: quickTranslation,
                            );
                          } else {
                            searchState?.textController.clear();
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}