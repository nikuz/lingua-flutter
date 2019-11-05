import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/widgets/pronunciation/pronunciation.dart';

import './model/item.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _translationsBloc = BlocProvider.of<TranslationsBloc>(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _translationsBloc.add(TranslationsRequest());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationsBloc, TranslationsState>(
      builder: (context, state) {
        if (state is TranslationsLoaded) {
          if (state.translations.isEmpty) {
            return Center(
              child: Text('no translations'),
            );
          }

          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return index >= state.translations.length
                  ? BottomLoader()
                  : TranslationsListItemWidget(
                      translationItem: state.translations[index]
                  );
            },
            itemCount: state.translations.length + 1,
            controller: _scrollController,
          );
        }

        if (state is TranslationsError) {
          return Center(
            child: Text(state.error.message),
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class TranslationsListItemWidget extends StatelessWidget {
  final TranslationsItem translationItem;

  TranslationsListItemWidget({Key key, @required this.translationItem}) : super(key: key);

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
      child: ListTile(
        leading: PronunciationWidget(pronunciationUrl: translationItem.pronunciation),
        title: Text(
          translationItem.word,
          style: TextStyle(fontSize: 17),
        ),
        subtitle: Text(
          translationItem.translation,
          style: TextStyle(fontSize: 15),
        ),
        dense: true,
        trailing: Container(
          width: 50,
          child: Image.network(
            '${getApiUri()}${translationItem.image}',
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
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
}
