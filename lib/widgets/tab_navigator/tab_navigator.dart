import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

import './tab_navigator_constants.dart';
import './tab_navigator_item.dart';

export './tab_navigator_item.dart';
export './tab_navigator_constants.dart';

class TabNavigator extends StatefulWidget {
  final List<TabNavigatorItem> children;
  final Function(String label)? onSelectTab;

  TabNavigator({
    required this.children,
    this.onSelectTab,
  });

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBarThemeData bottomTheme = BottomNavigationBarTheme.of(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: TabNavigatorConstants.height,
        color: bottomTheme.backgroundColor,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 1,
              style: BorderStyle.solid,
              color: Colors.black.withOpacity(0.2),
            ), //BorderSide
          ), //
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for(var i = 0, l = widget.children.length; i < l; i++)
              widget.children[i].copyWith(
                index: i,
                active: i == _activeTabIndex,
                onPressed: (String path) {
                  int? index = widget.children.indexWhere((item) => item.path == path);
                  if (index != -1) {
                    setState(() {
                      _activeTabIndex = index;
                    });
                    AutoRouter.of(context).replaceNamed(path);
                  }
                }
              ),
          ],
        ),
      ),
    );
  }
}