import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

class SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsets? margin;
  final Widget child;

  const SettingsRow({
    Key? key,
    required this.title,
    this.subtitle,
    this.margin,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
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
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          child,
        ],
      ),
    );
  }
}