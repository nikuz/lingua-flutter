import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/providers/connectivity.dart';
import 'package:lingua_flutter/screens/settings/bloc/settings_cubit.dart';

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
  final TranslationContainer? quickTranslation;
  final Language? translateFrom;
  final Language? translateTo;

  const TranslationView({
    Key? key,
    required this.word,
    this.quickTranslation,
    this.translateFrom,
    this.translateTo,
  }) : super(key: key);

  @override
  State<TranslationView> createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> {
  late TranslationViewCubit _translationViewCubit;
  late ScrollController _scrollController;
  ScrollPhysics _scrollPhysics = const ClampingScrollPhysics();
  int? _translationId;
  bool _hasInternetConnection = false;

  @override
  void initState() {
    super.initState();
    _translationViewCubit = context.read<TranslationViewCubit>();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollHandler);

    if (widget.quickTranslation != null) {
      _translationViewCubit.setTranslation(widget.quickTranslation!);
      _fetchImages(widget.quickTranslation!.word);
      _translationViewCubit.fetchPronunciations(widget.quickTranslation!);
    } else {
      _fetchTranslation();
    }

    _getInternetConnectionStatus();
    subscribeToNetworkChange('translation_view', (bool isConnected) {
      setState(() {
        _hasInternetConnection = isConnected;
      });
    });
  }

  @override
  void didUpdateWidget(covariant TranslationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (
      oldWidget.word != widget.word
      || oldWidget.translateFrom != widget.translateFrom
      || oldWidget.translateTo != widget.translateTo
    ) {
      _fetchTranslation();
    }
  }

  @override
  void dispose() {
    _translationViewCubit.reset();
    _scrollController.removeListener(_scrollHandler);
    unsubscribeFromNetworkChange('translation_view');
    super.dispose();
  }

  void _scrollHandler() {
    final scrollPosition = _scrollController.position.pixels;
    final threshold = MediaQuery.of(context).size.height;
    if (scrollPosition < threshold && _scrollPhysics is! ClampingScrollPhysics) {
      setState(() => _scrollPhysics = const ClampingScrollPhysics());
    } else if (scrollPosition > threshold && _scrollPhysics is! BouncingScrollPhysics) {
      setState(() => _scrollPhysics = const BouncingScrollPhysics());
    }
  }

  void _getInternetConnectionStatus() async {
    bool connection = await isInternetConnected();
    setState(() {
      _hasInternetConnection = connection;
    });
  }

  void _fetchTranslation() {
    final settingsCubit = context.read<SettingsCubit>();
    _translationViewCubit.translate(
      widget.word,
      widget.translateFrom ?? settingsCubit.state.translateFrom,
      widget.translateTo ?? settingsCubit.state.translateTo,
    );
  }

  void _fetchImages(String word) {
    _translationViewCubit.fetchImages(word).then((String? image) {
      if (image != null) {
        _translationViewCubit.setImage(image);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // to automatically add Back Button when needed,
        title: Text(
          widget.word,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 25,
          ),
          onPressed: () {
            AutoRouter.of(context).pop();
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
              _fetchImages(state.translation!.word);
            }

            if (
              state.translation != null
              && state.translation!.pronunciationFrom == null
              && !state.pronunciationLoading
            ) {
              _translationViewCubit.fetchPronunciations(state.translation!);
            }

            if (state.translation?.id != null && _translationId == null) {
              setState(() {
                _translationId = state.translation!.id;
              });
            }
          },
          child: BlocBuilder<TranslationViewCubit, TranslationViewState>(
            builder: (context, state) {
              if (state.error != null) {
                return const Center(
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
                  controller: _scrollController,
                  physics: _scrollPhysics,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TranslationViewHeader(word: widget.word),
                      const TranslationViewAutoSpellingFix(),
                      const TranslationViewAlternativeTranslations(),
                      const TranslationViewDefinitions(),
                      const TranslationViewExamples(),
                    ],
                  ),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
