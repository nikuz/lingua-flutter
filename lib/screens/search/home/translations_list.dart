import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/widgets/pronunciation.dart';
import 'package:lingua_flutter/widgets/prompts.dart';
import 'package:lingua_flutter/screens/search/router.dart';
import 'package:lingua_flutter/screens/search/translation_view/bloc/bloc.dart';
import 'package:lingua_flutter/screens/search/translation_view/bloc/events.dart';
import 'package:lingua_flutter/widgets/resizable_image.dart';

import 'model/item.dart';
import 'model/list.dart';
import 'bloc/state.dart';
import 'bloc/events.dart';
import 'bloc/bloc.dart';

class TranslationsList extends StatefulWidget {
  @override
  _TranslationsListState createState() => _TranslationsListState();
}

class _TranslationsListState extends State<TranslationsList> {
  final _scrollController = ScrollController();
  late TranslationsBloc _translationsBloc;
  Completer<void>? _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _translationsBloc = BlocProvider.of<TranslationsBloc>(context);
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
    ) {
      _translationsBloc.add(TranslationsRequestMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TranslationsBloc, TranslationsState>(
      listener: (context, state) {
        if (state is TranslationsLoaded) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
        }
      },
      child: BlocBuilder<TranslationsBloc, TranslationsState>(
        builder: (context, state) {
          if (state is TranslationsLoaded && state.translations.isEmpty) {
            return Center(
              child: Text('No translations found in your dictionary'),
            );
          }

          if (state.translations.isNotEmpty) {
            return Container(
              child: RefreshIndicator(
                onRefresh: () {
                  if (state is TranslationsLoaded && state.search != null) {
                    _translationsBloc.add(TranslationsSearch(state.search!));
                  } else {
                    _translationsBloc.add(TranslationsRequest());
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
                              )
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
          }

          if (state is TranslationsError) {
            return Center(
              child: Text(state.error.message),
            );
          }

          if (!(state is TranslationsLoaded)) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Container();
        },
      ),
    );
  }
}

class TranslationsListItemWidget extends StatefulWidget {
  final TranslationsItem translationItem;
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
          BlocProvider.of<TranslationsBloc>(context).add(
              TranslationsItemRemove(widget.translationItem.id!)
          );
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
          leading: ResizableImage(
            width: 50,
            height: 50,
            imageSource: widget.translationItem.image,
            isLocal: true,
            withPreviewOverlay: true,
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
          ),
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
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.headline1!.color,
              ),
            ),
          ),
          dense: true,
          trailing: widget.translationItem.pronunciation != null ?
            PronunciationWidget(
              pronunciationUrl: widget.translationItem.pronunciation!,
              isLocal: true,
            )
            : null,
          onTap: () {
            BlocProvider.of<TranslationBloc>(context).add(TranslationClear());
            Navigator.pushNamed(
              context,
              SearchNavigatorRoutes.translation_view,
              arguments: {
                'word': widget.translationItem.word,
              },
            );
          },
        ),
      ),
    );
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationsBloc, TranslationsState>(
      builder: (context, state) {
        final int listLength = state.translations.length;
        if (listLength >= LIST_PAGE_SIZE && listLength < state.totalAmount!) {
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
