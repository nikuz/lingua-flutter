import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

enum SettingsRowType {
  container,
  link,
}

class SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsets? margin;
  final bool? isFirst;
  final bool? isLast;
  final SettingsRowType type;
  final VoidCallback? onPressed;
  final Widget child;

  const SettingsRow({
    Key? key,
    required this.title,
    this.subtitle,
    this.margin,
    this.isFirst,
    this.isLast,
    this.type = SettingsRowType.container,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  SettingsRow copyWith({
    String? title,
    String? subtitle,
    EdgeInsets? margin,
    bool? isFirst,
    bool? isLast,
    SettingsRowType? type,
    VoidCallback? onPressed,
    Widget? child,
  }) {
    return SettingsRow(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      margin: margin ?? this.margin,
      isFirst: isFirst ?? this.isFirst,
      isLast: isLast ?? this.isLast,
      type: type ?? this.type,
      onPressed: onPressed ?? this.onPressed,
      child: child ?? this.child,
    );
  }

  Widget _buildContent(BuildContext context) {
    final MyTheme theme = Styles.theme(context);

    return Container(
      padding: const EdgeInsets.only(
        right: 10,
        left: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    bool isFirst = this.isFirst == true;
    bool isLast = this.isLast == true;
    Border? border;
    Widget content = _buildContent(context);

    if (!isLast) {
      border = Border(
        bottom: BorderSide(color: theme.colors.divider),
      );
    }

    if (type == SettingsRowType.link) {
      final borderRadius = BorderRadius.vertical(
        top: Radius.circular(isFirst ? 8 : 0),
        bottom: Radius.circular(isLast ? 8 : 0),
      );
      content = Material(
        borderRadius: borderRadius,
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            if (onPressed != null) {
              onPressed!();
            }
          },
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      constraints: const BoxConstraints(
        minHeight: 50,
      ),
      decoration: BoxDecoration(
        border: border,
      ),
      child: content,
    );
  }
}