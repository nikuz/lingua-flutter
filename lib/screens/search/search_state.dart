import 'package:flutter/widgets.dart';

class SearchInheritedState extends InheritedWidget {
  final TextEditingController textController;
  final bool hasInternetConnection;
  final Function(String word) submitHandler;

  const SearchInheritedState({
    Key? key,
    required this.textController,
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