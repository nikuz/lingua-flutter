import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

import '../row/row.dart';

class SettingsCategory extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final EdgeInsets? margin;
  final List<SettingsRow> children;

  const SettingsCategory({
    Key? key,
    this.title,
    this.subtitle,
    this.margin,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Container(
              margin: const EdgeInsets.only(bottom: 5, left: 10),
              child: Text(
                title!.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colors.grey,
                ),
              ),
            ),

          Container(
            decoration: BoxDecoration(
              color: theme.colors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0, l = children.length; i < l; i++)
                  children[i].copyWith(
                    isFirst: i == 0,
                    isLast: i == l - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}