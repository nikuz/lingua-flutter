import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lingua_flutter/styles/styles.dart';

class Link extends StatelessWidget {
  final String text;
  final Uri? href;
  final VoidCallback? onPressed;

  const Link({
    super.key,
    required this.text,
    this.href,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (href != null) {
          launchUrl(href!);
        }
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: Text(
        text,
        style: TextStyle(
          color: Styles.colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
