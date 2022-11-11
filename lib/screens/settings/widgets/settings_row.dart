import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

class SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  SettingsRow({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  color: theme.colors.primary,
                ),
              ),

              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colors.grey,
                  ),
                )
            ],
          ),

          child,
        ],
      ),
    );
  }
}