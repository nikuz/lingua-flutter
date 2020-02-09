import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/widgets/word_remove_prompt.dart';

import 'package:lingua_flutter/screens/search/home/bloc/bloc.dart';
import 'package:lingua_flutter/screens/search/home/bloc/events.dart';

import 'bloc/bloc.dart';
import 'bloc/events.dart';
import 'bloc/state.dart';

import 'header.dart';
import 'other_translations.dart';
import 'definitions.dart';
import 'examples.dart';

class TranslationView extends StatefulWidget {
  final String word;

  TranslationView(this.word) : assert(word != null);

  @override
  _TranslationViewState createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> {
  TranslationBloc _translationBloc;
  String appBarTitle;
  bool appBarTitleUpdated = false;
  int wordId;

  @override
  void initState() {
    super.initState();
    _translationBloc = BlocProvider.of<TranslationBloc>(context);
    _translationBloc.add(TranslationRequest(widget.word));
    appBarTitle = widget.word;
  }

  @override
  void dispose() {
    if (!(_translationBloc.state is TranslationRequestLoading)) {
      _translationBloc.add(TranslationClear());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          title: Text(appBarTitle),
          leading: IconButton(icon:Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          elevation: 0,
          actions: <Widget>[
            //Add the dropdown widget to the `Action` part of our appBar. it can also be among the `leading` part
            PopupMenuButton<Menu>(
              icon: Icon(Icons.more_vert),
              onSelected: (Menu item) async {
                if (item.id == 'remove' && wordId != null) {
                  final bool removeAccepted = await wordRemovePrompt(context, appBarTitle, () {
                    BlocProvider.of<TranslationsBloc>(context).add(
                        TranslationsItemRemove(wordId)
                    );
                  });
                  if (removeAccepted) {
                    Navigator.pop(context, false);
                  }
                }
                if (item.id == 'image') {

                }
              },
              itemBuilder: (BuildContext context) {
                if (wordId == null) {
                  return null;
                }

                return menuList.map((Menu item) {
                  return PopupMenuItem<Menu>(
                    value: item,
                    child: Text(item.title),
                  );
                }).toList();
              },
            ),
          ],
      ),
      body: SafeArea(
        child: BlocListener<TranslationBloc, TranslationState>(
          listener: (context, state) {
            if (
              state is TranslationLoaded
              && state.image == null
              && state.images.isEmpty
              && state.strangeWord == false
              && state.imageLoading == false
              && isCyrillicWord(state.word) == false
            ) {
              _translationBloc.add(TranslationRequestImage(state.word));
            }

            if (state is TranslationLoaded && !appBarTitleUpdated) {
              setState(() {
                appBarTitle = state.word;
                wordId = state.id;
                appBarTitleUpdated = true;
              });
            }

            if (
              state is TranslationLoaded
              && (state.updateSuccess == true || state.saveSuccess == true)
            ) {
              Navigator.pop(context, false);
              _translationBloc.add(TranslationClear());
              BlocProvider.of<TranslationsBloc>(context).add(TranslationsRequest());
            }
          },
          child: BlocBuilder<TranslationBloc, TranslationState>(
            builder: (context, state) {
              Widget autoSpellingFix = Container();

              if (state is TranslationLoaded && state.autoSpellingFix != null) {
                autoSpellingFix = Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                    left: 10,
                    top: 4,
                    right: 10,
                    bottom: 6,
                  ),
                  color: Colors.red,
                  child: Wrap(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Text('Original word ', style: TextStyle(color: Colors.white)),
                      Text(
                        '"${state.autoSpellingFix}"',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(' had a spelling mistake', style: TextStyle(color: Colors.white))
                    ],
                  ),
                );
              }

              if (state is TranslationLoaded) {
                return SingleChildScrollView(
                  physics: new ClampingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      TranslationViewHeader(),
                      autoSpellingFix,
                      OtherTranslations(),
                      Definitions(),
                      Examples(),
                    ],
                  ),
                );
              }

              if (state is TranslationError) {
                return Center(
                  child: Text(state.error.message),
                );
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Menu {
  final String id;
  final String title;

  const Menu({this.id, this.title});
}

const List<Menu> menuList = const <Menu>[
  const Menu(id: 'image', title: 'Change Image'),
  const Menu(id: 'remove', title: 'Remove'),
];
