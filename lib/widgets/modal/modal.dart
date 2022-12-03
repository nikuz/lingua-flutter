import 'package:flutter/material.dart';

import 'package:lingua_flutter/styles/styles.dart';

class Modal {
  final BuildContext context;
  final List<Widget> children;

  const Modal({
    required this.context,
    required this.children,
  });

  static dismiss(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future show() {
    return showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
        final MyTheme theme = Styles.theme(context);
        final double screenWidth = MediaQuery.of(context).size.width;

        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: screenWidth - screenWidth * 0.2,
              margin: MediaQuery.of(context).viewInsets,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colors.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}