import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/providers/connectivity.dart';
import 'package:lingua_flutter/styles/styles.dart';

import './bloc/translation_view_cubit.dart';
import './bloc/translation_view_state.dart';

import './widgets/menu/menu.dart';
import './widgets/header/header.dart';
import './widgets/alternative_translations/alternative_translations.dart';
import './widgets/definitions/definitions.dart';
import './widgets/examples/examples.dart';
import './widgets/no_additional_data/no_additional_data.dart';
import './widgets/powered_by/powered_by.dart';
import './translation_view_state.dart';

class TranslationView extends StatefulWidget {
  final String word;
  final Language translateFrom;
  final Language translateTo;
  final TranslationContainer? quickTranslation;

  const TranslationView({
    Key? key,
    required this.word,
    required this.translateFrom,
    required this.translateTo,
    this.quickTranslation,
  }) : super(key: key);

  @override
  State<TranslationView> createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> with WidgetsBindingObserver {
  final headerKey = GlobalKey();
  late TranslationViewCubit _translationViewCubit;
  late ScrollController _scrollController;
  bool _hasInternetConnection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getInternetConnectionStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _translationViewCubit.reset();
    _scrollController.removeListener(_scrollHandler);
    unsubscribeFromNetworkChange('translation_view');
    super.dispose();
  }

  void _scrollHandler() {
    if (_scrollController.position.pixels < 0) _scrollController.jumpTo(0);
  }

  void _getInternetConnectionStatus() async {
    bool connection = await isInternetConnected();
    setState(() {
      _hasInternetConnection = connection;
    });
  }

  void _fetchTranslation() {
    _translationViewCubit.translate(
      widget.word,
      widget.translateFrom,
      widget.translateTo,
    );
  }

  void _fetchImages(String word) {
    _translationViewCubit.fetchImages(
      word,
      selectFirstImage: true,
      matchTranslationWord: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TranslationViewCubit, TranslationViewState>(
      listener: (context, state) {
        if (
          state.translation != null
          && state.translation!.image == null
          && state.images == null
          && !state.imageLoading
          && state.imageError == null
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
      },
      child: BlocBuilder<TranslationViewCubit, TranslationViewState>(
        builder: (context, state) {
          final MyTheme theme = Styles.theme(context);
          return Scaffold(
            backgroundColor: theme.colors.background,
            appBar: AppBar(
              automaticallyImplyLeading: true, // to automatically add Back Button when needed,
              backgroundColor: theme.colors.focusBackground,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: theme.colors.focusBackground,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              centerTitle: true,
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
                isNewWord: state.translation?.id == null,
                isDisabled: state.error != null,
                hasInternetConnection: _hasInternetConnection,
              ),
            ),
            body: SafeArea(
              child: TranslationViewInheritedState(
                headerKey: headerKey,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        TranslationViewHeader(
                          key: headerKey,
                          word: widget.word,
                        ),

                        if (state.translateLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 70),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),

                        if (state.error != null)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Cannot translate at the moment, \nplease try again later.',
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const TranslationViewNoAdditionalData(),
                        const TranslationViewAlternativeTranslations(),
                        const TranslationViewDefinitions(),
                        const TranslationViewExamples(),
                      ]),
                    ),
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: TranslationViewPoweredBy(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
