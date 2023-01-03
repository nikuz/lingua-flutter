import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

import './bottom_drawer_state.dart';

export './bottom_drawer_state.dart';

class BottomDrawer {
  final BuildContext context;
  final Widget Function(BuildContext, ScrollController) builder;
  final Map<String, Function> scrollListeners = {};

  BottomDrawer({
    required this.context,
    required this.builder,
  });

  static dismiss(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _subscribeToDrag(String name, Function callback) {
    scrollListeners[name] = callback;
  }

  void _unsubscribeFromDrag(String name) {
    scrollListeners.remove(name);
  }

  bool _onDragNotification(DraggableScrollableNotification notification) {
    scrollListeners.forEach((String key, Function listener) {
      listener(notification);
    });
    return false;
  }

  Future show() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final MyTheme theme = Styles.theme(context);

        return Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              left: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => BottomDrawer.dismiss(context),
                child: const SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            NotificationListener<DraggableScrollableNotification>(
              onNotification: _onDragNotification,
              child: DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (BuildContext context, ScrollController scrollController) {
                  return BottomDrawerInheritedState(
                    subscribeToDrag: _subscribeToDrag,
                    unsubscribeFromDrag: _unsubscribeFromDrag,
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: theme.colors.background,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                      child: builder(context, scrollController),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

