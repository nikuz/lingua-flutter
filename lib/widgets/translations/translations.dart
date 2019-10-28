import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/widgets/pronunciation/pronunciation.dart';

import './model/item.dart';
import './bloc/state.dart';
import './bloc/bloc.dart';

class TranslationsList extends StatelessWidget {
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
              return TranslationsListItemWidget(
                  translationItem: state.translations[index]
              );
            },
            itemCount: state.translations.length,
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: PronunciationWidget(pronunciationUrl: translationItem.pronunciation),
      title: Text(
        translationItem.word,
        style: TextStyle(fontSize: 17),
      ),
//      isThreeLine: true,
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
    );
  }
}
