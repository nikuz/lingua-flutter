import 'package:flutter/widgets.dart';
import 'package:lingua_flutter/controllers/request/request.dart' show CancelToken;

class TranslationViewInheritedState extends InheritedWidget {
  final GlobalKey headerKey;
  final CancelToken cancelToken;

  const TranslationViewInheritedState({
    super.key,
    required this.headerKey,
    required this.cancelToken,
    required Widget child,
  }) : super(child: child);

  static TranslationViewInheritedState? of(BuildContext context) => (
      context.dependOnInheritedWidgetOfExactType<TranslationViewInheritedState>()
  );

  @override
  bool updateShouldNotify(TranslationViewInheritedState oldWidget) => true;
}