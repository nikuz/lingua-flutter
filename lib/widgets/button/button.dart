import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

enum ButtonSize {
  regular,
  large,
}

enum ButtonShape {
  rectangular,
  oval,
}

class Button extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final double? iconSize;
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
  final bool loading;
  final bool disabled;
  final VoidCallback? onPressed;

  const Button({
    super.key,
    this.text,
    this.icon,
    this.iconSize,
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
    this.loading = false,
    this.disabled = false,
    this.onPressed,
  });

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
      border = Border.all(
        width: 1,
        style: BorderStyle.solid,
        color: borderColor,
      );
    }

    if (size == ButtonSize.large) {
      fontSize = 16;
    }

    if (shape == ButtonShape.oval) {
      inkWellBorder = const CircleBorder();
      widthConstraint = width ?? 50;
      heightConstraint = height ?? 50;
      borderRadius = BorderRadius.all(Radius.circular(widthConstraint));
      padding = EdgeInsets.zero;
    }

    if (elevated) {
      textColor = theme.brightness == Brightness.light ? Styles.colors.white : Styles.colors.fakeBlack;
      highlightColor = Styles.colors.white.withOpacity(0.1);
      splashColor = Styles.colors.white.withOpacity(0.2);
      elevation = !disabled ? 3 : 0;
      if (backgroundColor == Colors.transparent) {
        backgroundColor = theme.colors.focus;
      }
    }

    return Container(
      margin: margin,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: Material(
          type: MaterialType.button,
          color: backgroundColor,
          borderRadius: borderRadius,
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
                  if (loading)
                    CircularProgressIndicator(
                      backgroundColor: textColor,
                    ),

                  if (!loading && icon != null)
                    Container(
                      margin: EdgeInsets.only(right: text != null ? 5 : 0),
                      child: Icon(
                        icon,
                        color: textColor,
                        size: iconSize,
                      ),
                    ),

                  if (!loading && text != null)
                    Flexible(
                      child: Text(
                        text!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: textColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class ButtonBlue extends Button {
  ButtonBlue({
    super.key,
    super.text,
    super.icon,
    super.outlined,
    super.elevated,
    super.size,
    super.shape,
    super.width,
    super.height,
    super.margin,
    super.padding,
    super.borderColor,
    backgroundColor,
    highlightColor,
    splashColor,
    textColor,
    super.borderRadius,
    super.disabled,
    super.onPressed,
  }): super(
    backgroundColor: Styles.colors.blue,
    highlightColor: Styles.colors.white.withOpacity(0.1),
    splashColor: Styles.colors.white.withOpacity(0.2),
    textColor: Styles.colors.white,
  );
}