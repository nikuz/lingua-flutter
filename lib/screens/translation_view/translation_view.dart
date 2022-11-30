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

import './widgets/menu.dart';
import './widgets/header.dart';
import './widgets/auto_spelling_fix.dart';
import 'widgets/alternative_translations/alternative_translations.dart';
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
  late TranslationViewCubit _translationViewCubit;
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
    _translationViewCubit = context.read<TranslationViewCubit>();
    if (widget.word != null) {
      _translationViewCubit.translate(widget.word!);
    }
    _appBarTitle = widget.word;
    _getInternetConnectionStatus();
  }

  @override
  void dispose() {
    _translationViewCubit.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // to automatically add Back Button when needed,
        title: Text(
          _appBarTitle ?? '',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 25,
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        elevation: 0,
        actions: translationViewMenuConstructor(
          context: context,
          word: widget.word ?? '',
          imageSearchWord: _imageSearchWord,
          wordId: _wordId,
          disabled: _menuDisabled,
          hasInternetConnection: _hasInternetConnection,
        ),
      ),
      body: SafeArea(
        // child: Container(
        //   decoration: BoxDecoration(
        //     border: Border.all(color: Colors.green, width: 3),
        //   ),
        // ),
        child: BlocListener<TranslationViewCubit, TranslationViewState>(
          listener: (context, state) {
            // if (
            //   state.image == null
            //   && state.images.isEmpty
            //   && state.strangeWord == false
            //   && state.imageLoading == false
            //   && state.word is String
            //   && isCyrillicWord(state.word!) == false
            // ) {
            //   translationViewCubit.fetchImages(state.word!);
            // }
            //
            // if (!_appBarTitleUpdated) {
            //   setState(() {
            //     _appBarTitle = state.word;
            //     _wordId = state.id;
            //     _appBarTitleUpdated = true;
            //     _menuDisabled = _wordId == null || state.remote!;
            //   });
            // }
            //
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
              if (state.error?.message != null) {
                return Center(
                  child: Text(state.error?.message ?? ''),
                );
              }

              if (widget.word != null) {
                return SingleChildScrollView(
                  physics: new ClampingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      TranslationViewHeader(word: widget.word!),
                      TranslationViewAutoSpellingFix(),
                      TranslationViewAlternativeTranslations(),
                      // TranslationViewDefinitions(),
                      // TranslationViewExamples(),
                    ],
                  ),
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
