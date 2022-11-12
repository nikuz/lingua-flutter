import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/widgets/pronunciation.dart';
import 'package:lingua_flutter/widgets/prompts.dart';
import 'package:lingua_flutter/widgets/image_preview.dart';
import 'package:lingua_flutter/screens/translation_view/models/translation.model.dart';
import 'package:lingua_flutter/screens/router.gr.dart';

import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';
import '../search_constants.dart';

class SearchTranslationsList extends StatefulWidget {
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
          if (state.translations.isEmpty) {
            if (state.loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: Text('No translations found in your dictionary'),
              );
            }
          }

          if (state.error != null) {
            return Center(
              child: Text(state.error.message),
            );
          }

          return Container(
            child: RefreshIndicator(
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
                      padding: EdgeInsets.only(
                        left: 15,
                        top: 10,
                      ),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Total: ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${state.totalAmount}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (index - 1 == state.translations.length) {
                    return BottomLoader();
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

  TranslationsListItemWidget({
    Key? key,
    required this.translationItem,
    required this.withBorder,
  }) : super(key: key);

  @override
  _TranslationsListItemWidgetState createState() => _TranslationsListItemWidgetState();
}

class _TranslationsListItemWidgetState extends State<TranslationsListItemWidget> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.translationItem.word!),
      background: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
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
      confirmDismiss: (DismissDirection direction) async {
        return await wordRemovePrompt(context, widget.translationItem.word, () {
          if (widget.translationItem.id != null) {
            context.read<SearchCubit>().removeTranslation(widget.translationItem.id!);
          }
        });
      },
      direction: DismissDirection.endToStart,
      child: Container(
        margin: EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: widget.withBorder ? Theme.of(context).dividerColor : Color.fromRGBO(0, 0, 0, 0.0),
            ),
          ),
          color: isSelected ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor,
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
            margin: EdgeInsets.only(bottom: 2),
            child: Text(
              widget.translationItem.word!,
              style: TextStyle(
                fontSize: 18,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.headline1!.decorationColor,
              ),
            ),
          ),
          subtitle: Container(
            margin: EdgeInsets.only(bottom: 2),
            child: Text(
              widget.translationItem.translation!,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.white : Theme.of(context).textTheme.headline1!.color,
              ),
            ),
          ),
          dense: true,
          trailing: widget.translationItem.pronunciation != null
              ? PronunciationWidget(pronunciationSource: widget.translationItem.pronunciation!)
              : null,
          onTap: () {
            AutoRouter.of(context).push(TranslationViewRoute(word: widget.translationItem.word));
          },
        ),
      ),
    );
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final int listLength = state.translations.length;
        if (listLength >= SearchConstants.itemsPerPage && listLength < state.totalAmount) {
          return Container(
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
