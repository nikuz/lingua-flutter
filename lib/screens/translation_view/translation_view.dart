import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/controllers/request/request.dart' show CancelToken;
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/models/quick_translation/quick_translation.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';
import 'package:lingua_flutter/controllers/connectivity/connectivity.dart';
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

@RoutePage<TranslationContainer>()
class TranslationViewScreen extends StatefulWidget {
  final String word;
  final Language translateFrom;
  final Language translateTo;
  final QuickTranslation? quickTranslation;

  const TranslationViewScreen({
    super.key,
    required this.word,
    required this.translateFrom,
    required this.translateTo,
    this.quickTranslation,
  });

  @override
  State<TranslationViewScreen> createState() => _TranslationViewScreenState();
}

class _TranslationViewScreenState extends State<TranslationViewScreen> with WidgetsBindingObserver {
  final headerKey = GlobalKey();
  late TranslationViewCubit _translationViewCubit;
  late ScrollController _scrollController;
  bool _hasInternetConnection = false;
  final CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _translationViewCubit = context.read<TranslationViewCubit>();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollHandler);

    _fetchTranslation();
    final quickTranslation = widget.quickTranslation;

    if (quickTranslation != null) {
      _translationViewCubit.setTranslation(TranslationContainer.fromQuickTranslation(quickTranslation));
      _fetchImages(quickTranslation.word);
      _translationViewCubit.fetchPronunciations(
        word: quickTranslation.word,
        translateFrom: quickTranslation.translateFrom,
        translation: quickTranslation.translation,
        translateTo: quickTranslation.translateTo,
        cancelToken: _cancelToken,
      );
    }

    _getInternetConnectionStatus();
    subscribeToNetworkChange('translation_view', (bool isConnected) {
      setState(() {
        _hasInternetConnection = isConnected;
      });
    });
  }

  @override
  void didUpdateWidget(covariant TranslationViewScreen oldWidget) {
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
    _cancelToken.cancel();
    _scrollController.removeListener(_scrollHandler);
    unsubscribeFromNetworkChange('translation_view');
    _translationViewCubit.reset();
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
      word: widget.word,
      translateFrom: widget.translateFrom,
      translateTo: widget.translateTo,
      cancelToken: _cancelToken,
    );
  }

  void _fetchImages(String word) {
    _translationViewCubit.fetchImages(
      word,
      selectFirstImage: true,
      cancelToken: _cancelToken,
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
          _translationViewCubit.fetchPronunciations(
            word: state.translation!.word,
            translateFrom: state.translation!.translateFrom,
            translation: state.translation!.translation,
            translateTo: state.translation!.translateTo,
            cancelToken: _cancelToken,
          );
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
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              centerTitle: true,
              title: Text(
                widget.word,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: Colors.white,
                ),
                onPressed: () {
                  AutoRouter.of(context).pop();
                },
              ),
              elevation: 0,
              actions: translationViewMenuConstructor(
                context: context,
                isNewWord: state.translation?.id == null,
                isDisabled: state.translation == null || state.error != null,
                hasInternetConnection: _hasInternetConnection,
              ),
            ),
            body: SafeArea(
              child: TranslationViewInheritedState(
                headerKey: headerKey,
                cancelToken: _cancelToken,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 70),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: theme.colors.focus,
                              ),
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

                        if (!state.translateLoading)
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
