import 'package:flutter/material.dart';

import 'package:lingua_flutter/widgets/modal/modal.dart';

class Prompt {
  final BuildContext context;
  final String title;
  final Widget? child;
  final bool withCancel;
  final VoidCallback acceptCallback;
  final VoidCallback? cancelCallback;

  const Prompt({
    required this.context,
    required this.title,
    this.child,
    this.withCancel = true,
    required this.acceptCallback,
    this.cancelCallback,
  });

  Future show() {
    return Modal(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 5,
              right: 5,
              bottom: 10,
              left: 5,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),

          if (child != null)
            child!,

          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (withCancel)
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop(false);
                        if (cancelCallback != null) {
                          cancelCallback!();
                        }
                      },
                      child: const Text('CANCEL'),
                    ),
                  ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(true);
                    acceptCallback();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ],
      ),
    ).show();
  }
}