import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/widgets/prompt/prompt.dart';
import 'package:lingua_flutter/widgets/pronunciation/pronunciation.dart';
import 'package:lingua_flutter/widgets/image_preview/image_preview.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';
import '../search_constants.dart';

class SearchTranslationsList extends StatefulWidget {
  const SearchTranslationsList({Key? key}) : super(key: key);

  @override
  State<SearchTranslationsList> createState() => _SearchTranslationsListState();
}

class _SearchTranslationsListState extends State<SearchTranslationsList> {
  final _scrollController = ScrollController();
  late SearchCubit _searchCubit;
  Completer<void>? _refreshCompleter;

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchCubit, SearchState>(
      listener: (context, state) {
        if (!state.loading && _refreshCompleter != null && !_refreshCompleter!.isCompleted) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
        }
      },
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state.error?.message != null) {
            return Center(
              child: Text(state.error?.message ?? ''),
            );
          }

          if (state.translations.isEmpty) {
            if (state.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return const Center(
                child: Text('No translations found in your dictionary'),
              );
            }
          }

          return RefreshIndicator(
            onRefresh: () {
              if (state.searchText != null) {
                _searchCubit.fetchTranslations(searchText: state.searchText);
              } else {
                _searchCubit.fetchTranslations();
              }
              return _refreshCompleter!.future;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Container(
                    padding: const EdgeInsets.only(
                      left: 15,
                      top: 10,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Text(
                          'Total: ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.totalAmount}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (index - 1 == state.translations.length) {
                  return const BottomLoader();
                }

                return TranslationsListItemWidget(
                  key: ValueKey('$index-${state.translations[index - 1].updatedAt}'),
                  translationItem: state.translations[index - 1],
                  withBorder: index < state.translations.length,
                );
              },
              itemCount: state.translations.length + 2,
              controller: _scrollController,
            ),
          );
        },
      ),
    );
  }
}

class TranslationsListItemWidget extends StatefulWidget {
  final Translation translationItem;
  final bool withBorder;

  const TranslationsListItemWidget({
    Key? key,
    required this.translationItem,
    required this.withBorder,
  }) : super(key: key);

  @override
  State<TranslationsListItemWidget> createState() => _TranslationsListItemWidgetState();
}

class _TranslationsListItemWidgetState extends State<TranslationsListItemWidget> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return Dismissible(
          key: Key(widget.translationItem.word),
          background: Container(
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                SizedBox(
                  width: 80,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (DismissDirection direction) {
            final completer = Completer<bool>();

            Prompt(
              context: context,
              title: 'Delete "${widget.translationItem.word}" word?',
              acceptCallback: () {
                if (widget.translationItem.id != null) {
                  context.read<SearchCubit>().removeTranslation(widget.translationItem.id!);
                }
              },
            ).show().then((value) {
              completer.complete(value == true);
            });

            return completer.future;
          },
          direction: DismissDirection.endToStart,
          child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: widget.withBorder ? Theme
                      .of(context)
                      .dividerColor : const Color.fromRGBO(0, 0, 0, 0.0),
                ),
              ),
              color: isSelected ? Theme
                  .of(context)
                  .colorScheme
                  .secondary : Theme
                  .of(context)
                  .scaffoldBackgroundColor,
            ),
            child: ListTile(
              leading: widget.translationItem.image != null
                  ? ImagePreview(
                  width: 50,
                  height: 50,
                  imageSource: widget.translationItem.image!,
                  onTap: () {
                    setState(() {
                      isSelected = true;
                    });
                  },
                  onPreviewClose: () {
                    setState(() {
                      isSelected = false;
                    });
                  }
              )
                  : null,
              title: Container(
                margin: const EdgeInsets.only(bottom: 2),
                child: Text(
                  widget.translationItem.word,
                  style: TextStyle(
                    fontSize: 18,
                    color: isSelected
                        ? Colors.white
                        : Theme
                        .of(context)
                        .textTheme
                        .headline1!
                        .decorationColor,
                  ),
                ),
              ),
              subtitle: Container(
                margin: const EdgeInsets.only(bottom: 2),
                child: Text(
                  widget.translationItem.translation!,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Theme
                        .of(context)
                        .textTheme
                        .headline1!
                        .color,
                  ),
                ),
              ),
              dense: true,
              trailing: widget.translationItem.pronunciation != null
                  ? PronunciationWidget(pronunciationSource: widget.translationItem.pronunciation!)
                  : null,
              onTap: () async {
                final searchCubit = context.read<SearchCubit>();
                final result = await AutoRouter.of(context).push<Translation>(
                    TranslationViewRoute(word: widget.translationItem.word)
                );
                if (result != null) {
                  if (state.translations.any((item) => item.id == result.id)) {
                    searchCubit.updateTranslation(result);
                  }
                }
              },
            ),
          ),
        );
      }
    );
  }
}

class BottomLoader extends StatelessWidget {
  const BottomLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final int listLength = state.translations.length;
        if (listLength >= SearchConstants.itemsPerPage && listLength < state.totalAmount) {
          return const Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Center(
              child: SizedBox(
                width: 33,
                height: 33,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                ),
              ),
            ),
          );
        }

        return Container();
      }
    );
  }
}
