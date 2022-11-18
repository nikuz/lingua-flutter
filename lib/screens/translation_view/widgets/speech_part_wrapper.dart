import 'package:flutter/material.dart';
import 'package:lingua_flutter/utils/string.dart';

// wrapper class to represent speech parts, such as: noun, pronoun, verb, adjective, etc.
class TranslationViewSpeechPartWrapper extends StatelessWidget {
  final List<dynamic> category;
  final int maxItemsToShow;
  final bool expanded;
  final Widget Function(BuildContext, int) itemBuilder;

  const TranslationViewSpeechPartWrapper({
    Key? key,
    required this.category,
    required this.maxItemsToShow,
    required this.expanded,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget categoryName;
    final List<dynamic> items = category[1];
    int itemsLength = items.length;

    if (category[0] != null) {
      String name = category[0];
      categoryName = Container(
        margin: EdgeInsets.only(
          bottom: 5,
        ),
        child: Text(
          '${name.capitalize()}',
          style: TextStyle(
            fontSize: 16,
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
      margin: EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          categoryName,
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: itemsLength,
            itemBuilder: itemBuilder,
          ),
        ],
      ),
    );
  }
}
