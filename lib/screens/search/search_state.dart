import 'package:flutter/widgets.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/models/quick_translation/quick_translation.dart';

class SearchInheritedState extends InheritedWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool hasInternetConnection;
  final Function(String word, {
    required Language translateFrom,
    required Language translateTo,
    QuickTranslation? quickTranslation,
  }) submitHandler;
  final Function(String name, Function callback) subscribeToListScroll;
  final Function(String name) unsubscribeFromListScroll;
  final Function(ScrollNotification notification) broadcastListScroll;
  final double Function() getPaddingTop;

  const SearchInheritedState({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.hasInternetConnection,
    required this.submitHandler,
    required this.subscribeToListScroll,
    required this.unsubscribeFromListScroll,
    required this.broadcastListScroll,
    required this.getPaddingTop,
    required super.child,
  });

  static SearchInheritedState? of(BuildContext context) => (
      context.dependOnInheritedWidgetOfExactType<SearchInheritedState>()
  );

  @override
  bool updateShouldNotify(SearchInheritedState oldWidget) => true;
}