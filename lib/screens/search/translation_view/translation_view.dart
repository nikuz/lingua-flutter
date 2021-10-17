import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/sizes.dart';
import 'package:lingua_flutter/utils/connectivity.dart';
import 'package:lingua_flutter/widgets/prompts.dart';

import 'package:lingua_flutter/screens/search/router.dart';
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
  String imageSearchWord;
  String translationWord;
  bool menuDisabled = false;
  bool _hasInternetConnection = false;

  @override
  void initState() {
    super.initState();
    _translationBloc = BlocProvider.of<TranslationBloc>(context);
    _translationBloc.add(TranslationRequest(widget.word));
    appBarTitle = widget.word;
    _getInternetConnectionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          title: Text(
            appBarTitle,
            style: TextStyle(
              fontSize: SizeUtil.vmax(20),
            ),
          ),
          leading: IconButton(icon: Icon(
              Icons.arrow_back,
              size: SizeUtil.vmax(25),
          ),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          elevation: 0,
          actions: <Widget>[
            PopupMenuButton<Menu>(
              icon: Icon(Icons.more_vert),
              enabled: !menuDisabled,
              onSelected: (Menu item) async {
                if (item.id == 'remove') {
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
                  Navigator.pushNamed(
                    context,
                    SearchNavigatorRoutes.translation_view_images_picker,
                    arguments: imageSearchWord,
                  );
                }
                if (item.id == 'translation') {
                  Navigator.pushNamed(
                    context,
                    SearchNavigatorRoutes.translation_view_own_translation,
                    arguments: translationWord,
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                if (menuDisabled) {
                  return null;
                }

                List<Menu> menuList = <Menu>[
                  const Menu(id: 'image', title: 'Change Image'),
                  const Menu(id: 'translation', title: 'Change Translation'),
                  const Menu(id: 'remove', title: 'Remove'),
                ];

                if (!_hasInternetConnection) {
                  menuList.removeAt(0);
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
                menuDisabled = wordId == null || state.remote;
              });
            }

            if (state is TranslationLoaded && state.imageSearchWord != imageSearchWord) {
              setState(() {
                imageSearchWord = state.imageSearchWord;
                translationWord = state.translationWord;
              });
            }

            if (
              state is TranslationLoaded
              && (state.updateSuccess == true || state.saveSuccess == true)
            ) {
              Navigator.pop(context, false);
              _translationBloc.add(TranslationClear());
              if (state.saveSuccess == true) {
                BlocProvider.of<TranslationsBloc>(context).add(TranslationsRequest());
              } else if (state.updateSuccess) {
                BlocProvider.of<TranslationsBloc>(context).add(
                    TranslationsUpdateItem(
                      id: state.id,
                      word: state.word,
                      translation: (
                          state.translationOwn != null
                              ? state.translationOwn
                              : state.translationWord
                      ),
                      pronunciation: state.pronunciation,
                      imageUrl: state.imageUrl,
                      image: state.image,
                      createdAt: state.createdAt,
                      updatedAt: '${new DateTime.now().millisecondsSinceEpoch}',
                    )
                );
              }
            }
          },
          child: BlocBuilder<TranslationBloc, TranslationState>(
            builder: (context, state) {
              Widget autoSpellingFix = Container();

              if (state is TranslationLoaded && state.autoSpellingFix != null) {
                autoSpellingFix = Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                    left: SizeUtil.vmax(10),
                    top: SizeUtil.vmax(4),
                    right: SizeUtil.vmax(10),
                    bottom: SizeUtil.vmax(6),
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
                      TranslationViewHeader(widget.word),
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

  void _getInternetConnectionStatus() async {
    bool connection = await isInternetConnected();
    setState(() {
      _hasInternetConnection = connection;
    });
  }
}

class Menu {
  final String id;
  final String title;

  const Menu({this.id, this.title});
}
