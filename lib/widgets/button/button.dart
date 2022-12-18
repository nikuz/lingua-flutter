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
  final Color? backgroundColor;
  final Color? highlightColor;
  final Color? splashColor;
  final Color? textColor;
  final double borderRadius;
  final bool disabled;
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
    this.backgroundColor,
    this.highlightColor,
    this.splashColor,
    this.textColor,
    this.borderRadius = 4,
    this.disabled = false,
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
    Color highlightColor = this.highlightColor ?? theme.colors.focus.withOpacity(0.1);
    Color splashColor = this.splashColor ?? theme.colors.focus.withOpacity(0.2);
    Color backgroundColor = this.backgroundColor ?? Colors.transparent;
    double elevation = 0;
    EdgeInsets padding = this.padding ?? const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 5,
    );

    if (outlined) {
      Color borderColor = this.borderColor ?? theme.colors.divider;
      if (disabled) {
        borderColor = borderColor.withOpacity(0.05);
      }
      border = Border.all(
        width: 1,
        style: BorderStyle.solid,
        color: borderColor,
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
      padding = EdgeInsets.zero;
    }

    if (elevated) {
      textColor = Styles.colors.white;
      highlightColor = Styles.colors.white.withOpacity(0.1);
      splashColor = Styles.colors.white.withOpacity(0.2);
      elevation = 3;
      if (backgroundColor == Colors.transparent) {
        backgroundColor = theme.colors.focus;
      }
    }

    if (disabled) {
      if (backgroundColor != Colors.transparent) {
        backgroundColor = backgroundColor.withOpacity(0.5);
      }
      textColor = textColor.withOpacity(0.5);
    }

    return Container(
      margin: margin,
      child: Material(
        type: MaterialType.button,
        color: backgroundColor,
        borderRadius: borderRadius,
        clipBehavior: Clip.hardEdge,
        elevation: elevation,
        child: InkWell(
          customBorder: inkWellBorder,
          highlightColor: highlightColor,
          splashColor: splashColor,
          onTap: disabled ? null : onPressed,
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


class ButtonBlue extends Button {
  ButtonBlue({
    Key? key,
    text,
    icon,
    outlined = true,
    elevated = false,
    size = ButtonSize.regular,
    shape = ButtonShape.rectangular,
    width,
    height,
    margin,
    padding,
    borderColor,
    backgroundColor,
    highlightColor,
    splashColor,
    textColor,
    borderRadius = 4.0,
    disabled = false,
    onPressed,
  }): super(
    key: key,
    text: text,
    icon: icon,
    outlined: outlined,
    elevated: elevated,
    size: size,
    shape: shape,
    width: width,
    height: height,
    margin: margin,
    padding: padding,
    borderColor: borderColor,
    backgroundColor: Styles.colors.blue,
    highlightColor: Styles.colors.white.withOpacity(0.1),
    splashColor: Styles.colors.white.withOpacity(0.2),
    textColor: Styles.colors.white,
    borderRadius: borderRadius,
    disabled: disabled,
    onPressed: onPressed,
  );
}