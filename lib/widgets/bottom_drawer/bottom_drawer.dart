import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

class BottomDrawer {
  final BuildContext context;
  final Widget Function(BuildContext, ScrollController) builder;

  const BottomDrawer({
    required this.context,
    required this.builder,
  });

  static dismiss(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
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
            DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: theme.colors.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: builder(context, scrollController),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

