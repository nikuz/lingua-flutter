import 'package:flutter/material.dart';

import './modal_content.dart';

class Modal {
  final BuildContext context;
  final Widget child;
  final bool isFramed;
  final bool isZoomable;

  const Modal({
    required this.context,
    required this.child,
    this.isFramed = true,
    this.isZoomable = false,
  });

  static dismiss(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future show() {
    return showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
        return ModalContent(
          isFramed: isFramed,
          isZoomable: isZoomable,
          close: () {
            Modal.dismiss(context);
          },
          child: child,
        );
      },
    );
  }
}

