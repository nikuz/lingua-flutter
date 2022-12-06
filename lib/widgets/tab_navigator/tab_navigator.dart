import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_flutter/styles/styles.dart';

import './tab_navigator_constants.dart';
import './tab_navigator_item.dart';

export './tab_navigator_item.dart';
export './tab_navigator_constants.dart';

class TabNavigator extends StatefulWidget {
  final List<TabNavigatorItem> children;
  final Function(String label)? onSelectTab;

  const TabNavigator({
    Key? key,
    required this.children,
    this.onSelectTab,
  }) : super(key: key);

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final MyTheme theme = Styles.theme(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: TabNavigatorConstants.height + bottomPadding,
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
          color: theme.colors.background,
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