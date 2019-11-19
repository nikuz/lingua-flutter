import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/widgets/pronunciation.dart';
import 'package:lingua_flutter/router.dart';

import './model/item.dart';
import './model/list.dart';
import './bloc/state.dart';
import './bloc/events.dart';
import './bloc/bloc.dart';

class TranslationsList extends StatefulWidget {
  @override
  _TranslationsListState createState() => _TranslationsListState();
}

class _TranslationsListState extends State<TranslationsList> {
  final _scrollController = ScrollController();
  TranslationsBloc _translationsBloc;
  Completer<void> _refreshCompleter;

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
              child: Text('no translations'),
            );
          }

          if (state.translations.isNotEmpty) {
            return Container(
              color: Colors.white,
              child: RefreshIndicator(
                onRefresh: () {
                  if (state is TranslationsLoaded && state.search != null) {
                    _translationsBloc.add(TranslationsSearch(state.search));
                  } else {
                    _translationsBloc.add(TranslationsRequest());
                  }
                  return _refreshCompleter.future;
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
                            Text('Total: '),
                            Text('${state.totalAmount}', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }

                    if (index - 1 == state.translations.length) {
                      return BottomLoader();
                    }

                    return TranslationsListItemWidget(
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

          return null;
        },
      ),
    );
  }
}

class TranslationsListItemWidget extends StatelessWidget {
  final TranslationsItem translationItem;
  final bool withBorder;

  TranslationsListItemWidget({
    Key key,
    @required this.translationItem,
    @required this.withBorder,
  }) : super(key: key);

  Future<bool> confirmRowDelete(context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text('Are you sure you wish to delete "${translationItem.word}" word?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                BlocProvider.of<TranslationsBloc>(context).add(
                  TranslationsItemRemove(translationItem.id)
                );
              },
              child: const Text("DELETE")
            ),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(translationItem.word),
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
        return await confirmRowDelete(context);
      },
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        print(direction);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: withBorder ? Color.fromRGBO(0, 0, 0, 0.1) : Color.fromRGBO(0, 0, 0, 0.0),
            ),
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 50,
            child: Image.network(
              '${getApiUri()}${translationItem.image}',
              fit: BoxFit.fitHeight,
            ),
          ),
          title: Text(
            translationItem.word,
            style: TextStyle(fontSize: 17),
          ),
          subtitle: Text(
            translationItem.translation,
            style: TextStyle(fontSize: 15),
          ),
          dense: true,
          trailing: PronunciationWidget(pronunciationUrl: translationItem.pronunciation),
          onTap: () {
            Navigator.pushNamed(
              context,
              TRANSLATION_VIEW,
              arguments: translationItem.word,
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
        if (listLength >= LIST_PAGE_SIZE && listLength < state.totalAmount) {
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
