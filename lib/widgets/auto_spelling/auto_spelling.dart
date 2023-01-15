import 'package:flutter/material.dart';
import 'package:lingua_flutter/models/translation.dart';
import 'package:lingua_flutter/styles/styles.dart';

class AutoSpelling extends StatelessWidget {
  final TranslationContainer? translation;
  final EdgeInsets? padding;
  final Color? color;
  final Function(String)? onPressed;

  const AutoSpelling({
    super.key,
    this.translation,
    this.padding,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (translation == null || translation!.id != null || translation!.autoSpelling == null) {
      return Container();
    }

    final isInDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = isInDarkMode ? Styles.colors.orange : Styles.colors.pumpkin;

    return GestureDetector(
      onTap: () {
        if (onPressed is Function && translation!.autoSpelling != null) {
          onPressed!(translation!.autoSpelling!);
        }
      },
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                Icons.auto_awesome,
                color: this.color ?? color,
              ),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: this.color ?? color,
                  ),
                  children: [
                    const TextSpan(text: 'Did you mean '),
                    TextSpan(
                      text: translation!.autoSpelling,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
