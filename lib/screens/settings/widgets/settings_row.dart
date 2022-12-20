import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

class SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsets? margin;
  final bool? isLast;
  final Widget child;

  const SettingsRow({
    Key? key,
    required this.title,
    this.subtitle,
    this.margin,
    this.isLast,
    required this.child,
  }) : super(key: key);

  SettingsRow copyWith({
    String? title,
    String? subtitle,
    EdgeInsets? margin,
    bool? isLast,
    Widget? child,
  }) {
    return SettingsRow(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      margin: margin ?? this.margin,
      isLast: isLast ?? this.isLast,
      child: child ?? this.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    bool isLast = this.isLast == true;
    Border? border;

    if (!isLast) {
      border = Border(
        bottom: BorderSide(color: theme.colors.divider),
      );
    }

    return Container(
      margin: margin,
      padding: const EdgeInsets.only(
        right: 10,
        bottom: 10,
        left: 10,
      ),
      decoration: BoxDecoration(
        border: border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  color: theme.colors.primary,
                ),
              ),

              child,
            ],
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
    );
  }
}