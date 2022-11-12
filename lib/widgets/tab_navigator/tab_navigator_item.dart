import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

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

    return Expanded(
      child: Center(
        child: Material(
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (onPressed is Function) {
                onPressed!(path);
              }
            },
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Icon(
                      icon,
                      color: active ? theme.colors.focus : theme.colors.primary,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? theme.colors.focus : theme.colors.primary,
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
