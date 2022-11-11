import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final bool? loading;
  final Color? color;
  final bool? disabled;
  final Function? onPressed;

  SettingsButton({
    this.text,
    this.icon,
    this.loading,
    this.color,
    this.disabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container();

    if (loading == true) {
      content = SizedBox(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      );
    } else {
      if (text != null) {
        content = Text(
          text!,
          style: TextStyle(
            color: color,
          ),
        );
      } else if (icon != null) {
        content = Icon(
          icon,
          size: 30,
          color: disabled == true
              ? Colors.grey
              : color ?? Colors.green,
        );
      }
    }
    return ButtonTheme(
      minWidth: 55,
      child: TextButton(
        child: content,
        onPressed: () {
          if (disabled != true && onPressed is Function) {
            onPressed!();
          }
        },
      ),
    );
  }
}