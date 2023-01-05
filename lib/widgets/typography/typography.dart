import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

enum TypographyVariant {
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
  body1,
  body2,
}

class TypographyText extends StatelessWidget {
  final String? text;
  final TypographyVariant variant;
  final TextStyle? style;
  final TextAlign? align;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final List<TextSpan>? children;

  const TypographyText({
    super.key,
    this.text,
    this.variant = TypographyVariant.body1,
    this.style,
    this.align,
    this.margin,
    this.padding,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    double fontSize = 14;

    switch (variant) {
      case TypographyVariant.h1:
        fontSize = 24;
        break;
      case TypographyVariant.h2:
        fontSize = 22;
        break;
      case TypographyVariant.h3:
        fontSize = 20;
        break;
      case TypographyVariant.h4:
        fontSize = 18;
        break;
      case TypographyVariant.h5:
        fontSize = 17;
        break;
      case TypographyVariant.h6:
        fontSize = 16;
        break;
      case TypographyVariant.body2:
        fontSize = 13;
        break;
      default:
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 10),
      child: SelectableText.rich(
        textAlign: align,
        style: style ?? TextStyle(
          color: theme.colors.primary,
          fontSize: fontSize,
          height: 1.5,
        ),
        TextSpan(
          text: text,
          children: children,
        ),
      ),
    );
  }
}
