import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/search_cubit.dart';
import '../../bloc/search_state.dart';
import '../../search_constants.dart';
import '../../search_state.dart';
import './search_list_item.dart';
import './search_list_bottom_loader.dart';

class SearchList extends StatefulWidget {
  const SearchList({Key? key}) : super(key: key);

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  final _scrollController = ScrollController();
  late SearchCubit _searchCubit;
  late Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchCubit = context.read<SearchCubit>();
    _refreshCompleter = Completer<void>();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (
      _scrollController.position.pixels > 0.0
      && _scrollController.position.pixels == _scrollController.position.maxScrollExtent
      && _searchCubit.state.totalAmount > _searchCubit.state.translations.length
    ) {
      _searchCubit.fetchTranslations(
        from: _searchCubit.state.to,
        to: _searchCubit.state.to + SearchConstants.itemsPerPage,
      );
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    final searchState = SearchInheritedState.of(context);
    final topPadding = searchState?.getPaddingTop() ?? 0;
    searchState?.broadcastListScroll(notification);

    if (notification is ScrollEndNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final scrollPosition = _scrollController.position.pixels;
        const halfSearchFieldHeight = SearchConstants.searchFieldHeight / 2;
        double? autoScrollPosition;

        if (scrollPosition < halfSearchFieldHeight) {
          autoScrollPosition = 0;
        } else if (scrollPosition > halfSearchFieldHeight && scrollPosition < SearchConstants.searchFieldHeight) {
          autoScrollPosition = topPadding - (topPadding - SearchConstants.searchFieldHeight);
          print('topPadding: $topPadding');
          print('autoScrollPosition: $autoScrollPosition');
        }

        if (autoScrollPosition != null) {
          _scrollController.animateTo(
            autoScrollPosition,
            duration: SearchConstants.appearanceAnimationDuration,
            curve: Curves.easeOut,
          );
        }
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchCubit, SearchState>(
      listener: (context, state) {
        if (!state.loading && _refreshCompleter.isCompleted == false) {
          _refreshCompleter.complete();
        }
      },
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          final searchState = SearchInheritedState.of(context);
          final topPadding = searchState?.getPaddingTop() ?? 0;

          return RefreshIndicator(
            edgeOffset: topPadding - 5, // minus shadow
            onRefresh: () {
              _refreshCompleter = Completer();
              if (state.searchText != null) {
                _searchCubit.fetchTranslations(searchText: state.searchText);
              } else {
                _searchCubit.fetchTranslations();
              }
              return _refreshCompleter.future;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: topPadding,
                ),
                itemCount: state.translations.length + 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Container(
                      padding: const EdgeInsets.only(
                        left: 15,
                        top: 10,
                      ),
                      child: Wrap(
                        children: [
                          Text(
                            state.totalAmount.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' word${state.totalAmount > 1 ? 's' : ''}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  if (index - 1 == state.translations.length) {
                    return const SearchListBottomLoader();
                  }

                  return SearchListItem(
                    key: ValueKey('$index-${state.translations[index - 1].updatedAt}'),
                    translationItem: state.translations[index - 1],
                    withBorder: index < state.translations.length,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}