import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

import './tab_navigator_constants.dart';

class TabNavigatorItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool active;
  final int? index;
  final Function(String path)? onPressed;

  const TabNavigatorItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.path,
    this.active = false,
    this.index,
    this.onPressed,
  }) : super(key: key);

  TabNavigatorItem copyWith({
    IconData? icon,
    String? label,
    String? path,
    bool? active,
    int? index,
    Function(String path)? onPressed,
  }) {
    return TabNavigatorItem(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      path: path ?? this.path,
      active: active ?? this.active,
      index: index ?? this.index,
      onPressed: onPressed ?? this.onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    Color color = theme.colors.primaryPale;

    if (active) {
      color = theme.colors.focus;
    }

    return Expanded(
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (onPressed is Function) {
                onPressed!(path);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(
                minWidth: TabNavigatorConstants.minItemWidth,
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Icon(
                      icon,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
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
