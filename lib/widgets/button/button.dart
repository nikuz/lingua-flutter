import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

enum ButtonSize {
  regular,
  large,
}

enum ButtonShape {
  rectangular,
  circular,
}

class Button extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final bool outlined;
  final bool elevated;
  final ButtonSize size;
  final ButtonShape shape;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? borderColor;
  final Color? textColor;
  final double borderRadius;
  final VoidCallback? onPressed;

  const Button({
    Key? key,
    this.text,
    this.icon,
    this.outlined = true,
    this.elevated = false,
    this.size = ButtonSize.regular,
    this.shape = ButtonShape.rectangular,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderColor,
    this.textColor,
    this.borderRadius = 4,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    double? widthConstraint = width;
    double? heightConstraint = height;
    Border? border;
    BorderRadius borderRadius = BorderRadius.all(Radius.circular(this.borderRadius));
    OutlinedBorder inkWellBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(this.borderRadius));
    double fontSize = 14;
    Color textColor = this.textColor ?? theme.colors.focus;
    Color highlightColor = theme.colors.focus.withOpacity(0.1);
    Color splashColor = theme.colors.focus.withOpacity(0.2);
    double elevation = 0;

    if (outlined) {
      border = Border.all(
        width: 1,
        style: BorderStyle.solid,
        color: borderColor ?? theme.colors.divider,
      );
    }

    if (size == ButtonSize.large) {
      fontSize = 16;
    }

    if (shape == ButtonShape.circular) {
      inkWellBorder = const CircleBorder();
      widthConstraint = width ?? 50;
      heightConstraint = height ?? 50;
      borderRadius = BorderRadius.all(Radius.circular(widthConstraint));
    }

    if (elevated) {
      textColor = Styles.colors.white;
      highlightColor = Styles.colors.white.withOpacity(0.1);
      splashColor = Styles.colors.white.withOpacity(0.2);
      elevation = 3;
    }

    return Container(
      margin: margin,
      child: Material(
        type: MaterialType.button,
        color: elevated ? theme.colors.focus : Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.hardEdge,
        elevation: elevation,
        child: InkWell(
          customBorder: inkWellBorder,
          highlightColor: highlightColor,
          splashColor: splashColor,
          onTap: onPressed,
          child: Container(
            width: widthConstraint,
            height: heightConstraint,
            padding: padding,
            decoration: BoxDecoration(
              border: border,
              borderRadius: borderRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Container(
                    margin: EdgeInsets.only(right: text != null ? 5 : 0),
                    child: Icon(
                      icon,
                      color: textColor,
                    ),
                  ),

                if (text != null)
                  Text(
                    text!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
