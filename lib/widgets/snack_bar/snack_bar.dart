import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

class CustomSnackBar {
  final BuildContext context;
  final String message;
  final Duration? duration;

  const CustomSnackBar({
    required this.context,
    required this.message,
    this.duration,
  });

  void show() {
    final MyTheme theme = Styles.theme(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: theme.colors.focus,
        duration: duration ?? const Duration(seconds: 3),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}