import 'package:flutter/widgets.dart';

class TranslationViewInheritedState extends InheritedWidget {
  final GlobalKey headerKey;

  const TranslationViewInheritedState({
    super.key,
    required this.headerKey,
    required Widget child,
  }) : super(child: child);

  static TranslationViewInheritedState? of(BuildContext context) => (
      context.dependOnInheritedWidgetOfExactType<TranslationViewInheritedState>()
  );

  @override
  bool updateShouldNotify(TranslationViewInheritedState oldWidget) => true;
}