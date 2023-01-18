import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

enum CustomSnackBarType {
  success,
  warning,
  error,
}

class CustomSnackBar {
  final BuildContext context;
  final String message;
  final CustomSnackBarType type;
  final Duration? duration;

  const CustomSnackBar({
    required this.context,
    required this.message,
    this.type = CustomSnackBarType.success,
    this.duration,
  });

  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void show() {
    Color? backgroundColor;

    switch (type) {
      case CustomSnackBarType.success:
        backgroundColor = Styles.colors.darkGreen;
        break;
      case CustomSnackBarType.warning:
        backgroundColor = Styles.colors.orange;
        break;
      case CustomSnackBarType.error:
        backgroundColor = Styles.colors.red;
        break;
      default:
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Styles.colors.white),
        ),
      ),
    );
  }
}