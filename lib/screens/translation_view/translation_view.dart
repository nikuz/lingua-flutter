import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lingua_flutter/utils/connectivity.dart';
// import 'package:lingua_flutter/screens/router.gr.dart';
// import 'package:lingua_flutter/screens/search/bloc/search_cubit.dart';

import './bloc/translation_view_cubit.dart';
import './bloc/translation_view_state.dart';

import './widgets/menu.dart';
import './widgets/header.dart';
import './widgets/auto_spelling_fix.dart';
import './widgets/alternative_translations/alternative_translations.dart';
import './widgets/definitions/definitions.dart';
import './widgets/examples/examples.dart';

class TranslationView extends StatefulWidget {
  final String word;

  TranslationView({
    Key? key,
    required this.word,
  }) : super(key: key);

  @override
  _TranslationViewState createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> {
  late TranslationViewCubit _translationViewCubit;
  int? _translationId;
  bool _hasInternetConnection = false;

  @override
  void initState() {
    super.initState();
    _translationViewCubit = context.read<TranslationViewCubit>();
    _translationViewCubit.translate(widget.word);
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
          widget.word,
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
          isDisabled: _translationId == null,
          hasInternetConnection: _hasInternetConnection,
        ),
      ),
      body: SafeArea(
        child: BlocListener<TranslationViewCubit, TranslationViewState>(
          listener: (context, state) {
            if (
              state.translation != null
              && state.translation!.image == null
              && state.images == null
              && !state.imageLoading
            ) {
              _translationViewCubit.fetchImages(state.translation!.word);
            }

            if (state.translation?.id != null && _translationId == null) {
              setState(() {
                _translationId = state.translation!.id;
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
              if (state.error != null) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Cannot translate at the moment, \nplease try again later.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (state.translation != null) {
                return SingleChildScrollView(
                  physics: new ClampingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      TranslationViewHeader(word: widget.word!),
                      TranslationViewAutoSpellingFix(),
                      TranslationViewAlternativeTranslations(),
                      TranslationViewDefinitions(),
                      TranslationViewExamples(),
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
