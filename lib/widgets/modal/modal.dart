import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/widgets/resize_container/resize_container.dart';

class Modal {
  final BuildContext context;
  final Widget child;
  final bool isFramed;

  const Modal({
    required this.context,
    required this.child,
    this.isFramed = true,
  });

  static dismiss(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future show() {
    Size? childSize;
    double screenHeight = MediaQuery.of(context).size.height;

    return showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
        final MyTheme theme = Styles.theme(context);
        Widget childWidget = ResizeContainer(
          onChange: (Size size) {
            childSize = size;
          },
          child: child,
        );

        if (isFramed) {
          final double screenWidth = MediaQuery.of(context).size.width;
          childWidget = Container(
            width: screenWidth - screenWidth * 0.2,
            margin: MediaQuery.of(context).viewInsets,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colors.background,
              borderRadius: BorderRadius.circular(4),
            ),
            child: childWidget,
          );
        }

        Widget content = Material(
          type: MaterialType.transparency,
          child: childWidget,
        );

        return SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Draggable(
                maxSimultaneousDrags: 1,
                axis: Axis.vertical,
                affinity: Axis.vertical,
                feedback: content,
                onDragEnd: (drag) {
                  if (childSize != null) {
                    double initialPosition = screenHeight / 2 - childSize!.height / 2;
                    double offset = (initialPosition - drag.offset.dy).abs();

                    if (offset > 200) {
                      Modal.dismiss(context);
                    }
                  }
                },
                childWhenDragging: Container(),
                child: content,
              ),
            ],
          ),
        );
      },
    );
  }
}