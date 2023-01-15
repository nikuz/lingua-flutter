import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

class Tag extends StatelessWidget {
  final String text;
  final String? prefix;
  final String? suffix;
  final Widget? child;
  final EdgeInsets? margin;
  final Function(String)? onPressed;

  const Tag({
    Key? key,
    required this.text,
    this.prefix,
    this.suffix,
    this.child,
    this.margin,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    const double borderRadius = 4;
    final textColor = theme.brightness == Brightness.light ? Styles.colors.white : Styles.colors.fakeBlack;

    return Container(
      margin: margin,
      child: Material(
        color: theme.colors.focus,
        borderRadius: const BorderRadius.all(Radius.circular(borderRadius)),
        child: InkWell(
          onTap: () {
            if (onPressed is Function) {
              String resultWord = text;
              if (prefix != null) {
                resultWord = '$prefix $resultWord';
              }
              if (suffix != null) {
                resultWord += ' $suffix';
              }
              onPressed!(resultWord);
            }
          },
          highlightColor: Styles.colors.white.withOpacity(0.1),
          splashColor: Styles.colors.white.withOpacity(0.2),
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          child: Container(
            padding: const EdgeInsets.only(
              top: 3,
              right: 8,
              bottom: 5,
              left: 8,
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: textColor,
                ),
                children: [
                  if (prefix != null)
                    TextSpan(text: '$prefix ', style: const TextStyle(fontWeight: FontWeight.bold)),

                  TextSpan(text: text),

                  if (suffix != null)
                    TextSpan(text: ' $suffix', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
