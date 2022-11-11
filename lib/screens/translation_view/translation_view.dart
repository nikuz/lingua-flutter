import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import 'package:lingua_flutter/utils/string.dart';
import 'package:lingua_flutter/utils/connectivity.dart';
import 'package:lingua_flutter/widgets/prompts.dart';
import 'package:lingua_flutter/screens/router.gr.dart';
import 'package:lingua_flutter/screens/search/bloc/search_cubit.dart';
// import 'package:lingua_flutter/screens/search/bloc/bloc.dart';
// import 'package:lingua_flutter/screens/search/bloc/events.dart';

import './bloc/translation_view_cubit.dart';
import './bloc/translation_view_state.dart';

import './widgets/header.dart';
import './widgets/other_translations.dart';
import './widgets/definitions.dart';
import './widgets/examples.dart';

class TranslationView extends StatefulWidget {
  final String? word;

  TranslationView({
    Key? key,
    this.word,
  }) : super(key: key);

  @override
  _TranslationViewState createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> {
  late TranslationViewCubit translationViewCubit;
  late String? _appBarTitle;
  bool _appBarTitleUpdated = false;
  int? _wordId;
  String? _imageSearchWord;
  String? _translationWord;
  bool _menuDisabled = false;
  bool _hasInternetConnection = false;

  @override
  void initState() {
    super.initState();
    translationViewCubit = context.read<TranslationViewCubit>();
    if (widget.word != null) {
      translationViewCubit.translate(widget.word!);
    }
    _appBarTitle = widget.word;
    _getInternetConnectionStatus();
  }

  @override
  void dispose() {
    translationViewCubit.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          title: Text(
            _appBarTitle ?? '',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          leading: IconButton(icon: Icon(
              Icons.arrow_back,
              size: 25,
          ),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          elevation: 0,
          actions: <Widget>[
            PopupMenuButton<Menu>(
              icon: Icon(Icons.more_vert),
              enabled: !_menuDisabled,
              onSelected: (Menu item) async {
                if (item.id == 'remove') {
                  final bool removeAccepted = await wordRemovePrompt(context, _appBarTitle, () {
                    if (_wordId != null) {
                      context.read<SearchCubit>().removeTranslation(_wordId!);
                    }
                  });
                  if (removeAccepted) {
                    Navigator.pop(context, false);
                  }
                }
                if (item.id == 'image') {
                  // AutoRouter.of(context).push(TranslationViewImagePickerRoute(word: _imageSearchWord));
                  // Navigator.pushNamed(
                  //   context,
                  //   SearchNavigatorRoutes.translation_view_images_picker,
                  //   arguments: {
                  //     'word': imageSearchWord,
                  //   },
                  // );
                }
                if (item.id == 'translation') {
                  // Navigator.pushNamed(
                  //   context,
                  //   SearchNavigatorRoutes.translation_view_own_translation,
                  //   arguments: {
                  //     'word': translationWord,
                  //   },
                  // );
                }
              },
              itemBuilder: (BuildContext context) {
                if (_menuDisabled) {
                  return [];
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
                    child: Text(item.title!),
                  );
                }).toList();
              },
            ),
          ],
      ),
      body: SafeArea(
        child: BlocListener<TranslationViewCubit, TranslationViewState>(
          listener: (context, state) {
            if (
              state.image == null
              && state.images.isEmpty
              && state.strangeWord == false
              && state.imageLoading == false
              && state.word is String
              && isCyrillicWord(state.word!) == false
            ) {
              translationViewCubit.fetchImages(state.word!);
            }

            if (!_appBarTitleUpdated) {
              setState(() {
                _appBarTitle = state.word;
                _wordId = state.id;
                _appBarTitleUpdated = true;
                _menuDisabled = _wordId == null || state.remote!;
              });
            }

            if (state.imageSearchWord != _imageSearchWord) {
              setState(() {
                _imageSearchWord = state.imageSearchWord;
                _translationWord = state.translationWord;
              });
            }

            // if (state.updateSuccess == true || state.saveSuccess == true) {
            //   Navigator.pop(context, false);
            //   _translationBloc.add(TranslationClear());
            //   // if (state.saveSuccess == true) {
            //   //   BlocProvider.of<TranslationsBloc>(context).add(TranslationsRequest());
            //   // } else if (state.updateSuccess!) {
            //   //   BlocProvider.of<TranslationsBloc>(context).add(TranslationsUpdateItem(
            //   //     id: state.id,
            //   //     word: state.word,
            //   //     translation: (state.translationOwn != null ? state.translationOwn : state.translationWord),
            //   //     pronunciation: state.pronunciation,
            //   //     imageUrl: state.imageUrl,
            //   //     image: state.image,
            //   //     createdAt: state.createdAt,
            //   //     updatedAt: '${new DateTime.now().millisecondsSinceEpoch}',
            //   //   ));
            //   // }
            // }
          },
          child: BlocBuilder<TranslationViewCubit, TranslationViewState>(
            builder: (context, state) {
              Widget autoSpellingFix = Container();

              if (state.autoSpellingFix != null) {
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

              if (widget.word != null) {
                return SingleChildScrollView(
                  physics: new ClampingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      TranslationViewHeader(widget.word!),
                      autoSpellingFix,
                      OtherTranslations(),
                      Definitions(),
                      Examples(),
                    ],
                  ),
                );
              }

              if (state.error != null && state.error.message != null) {
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
  final String? id;
  final String? title;

  const Menu({this.id, this.title});
}
