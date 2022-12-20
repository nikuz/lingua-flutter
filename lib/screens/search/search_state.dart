import 'package:flutter/widgets.dart';
import 'package:lingua_flutter/models/language.dart';
import 'package:lingua_flutter/models/translation.dart';

class SearchInheritedState extends InheritedWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool hasInternetConnection;
  final Function(String word, {
    TranslationContainer? quickTranslation,
    Language? translateFrom,
    Language? translateTo,
  }) submitHandler;

  const SearchInheritedState({
    Key? key,
    required this.textController,
    required this.focusNode,
    required this.hasInternetConnection,
    required this.submitHandler,
    required Widget child,
  }) : super(key: key, child: child);

  static SearchInheritedState? of(BuildContext context) => (
      context.dependOnInheritedWidgetOfExactType<SearchInheritedState>()
  );

  @override
  bool updateShouldNotify(SearchInheritedState oldWidget) => (
      oldWidget.hasInternetConnection != hasInternetConnection
  );
}