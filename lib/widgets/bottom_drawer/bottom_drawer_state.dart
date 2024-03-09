import 'package:flutter/widgets.dart';

class BottomDrawerInheritedState extends InheritedWidget {
  final Function(String name, Function callback) subscribeToDrag;
  final Function(String name) unsubscribeFromDrag;

  const BottomDrawerInheritedState({
    super.key,
    required this.subscribeToDrag,
    required this.unsubscribeFromDrag,
    required super.child,
  });

  static BottomDrawerInheritedState? of(BuildContext context) => (
      context.dependOnInheritedWidgetOfExactType<BottomDrawerInheritedState>()
  );

  @override
  bool updateShouldNotify(BottomDrawerInheritedState oldWidget) => true;
}