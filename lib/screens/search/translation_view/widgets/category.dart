import 'package:flutter/material.dart';

import 'package:lingua_flutter/utils/sizes.dart';

class TranslationViewCategory extends StatelessWidget {
  final List<dynamic> category;
  final Function itemBuilder;
  final int maxItemsToShow;
  final bool expanded;

  TranslationViewCategory({
    Key? key,
    required this.category,
    required this.itemBuilder,
    required this.maxItemsToShow,
    required this.expanded
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget categoryName;
    final List<dynamic> items = category[1];
    int itemsLength = items.length;

    if (category[0] != null) {
      categoryName = Container(
        margin: EdgeInsets.only(
          bottom: SizeUtil.vmax(5),
        ),
        child: Text(
          '${category[0][0].toUpperCase()}${category[0].substring(1)}',
          style: TextStyle(
            fontSize: SizeUtil.vmax(16),
            color: Theme.of(context).buttonTheme.colorScheme?.secondaryContainer,
          ),
        ),
      );
    } else {
      categoryName = Container();
    }

    if (!expanded && itemsLength > maxItemsToShow) {
      itemsLength = maxItemsToShow;
    }

    return Container(
      margin: EdgeInsets.only(top: SizeUtil.vmax(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          categoryName,
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: itemBuilder as Widget Function(BuildContext, int),
            itemCount: itemsLength,
          ),
        ],
      ),
    );
  }
}
