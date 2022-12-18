import 'package:flutter/material.dart';
import 'package:lingua_flutter/utils/string.dart';

// wrapper class to represent speech parts, such as: noun, pronoun, verb, adjective, etc.
class TranslationViewSpeechPartWrapper extends StatelessWidget {
  final String? name;
  final List<dynamic>? items;
  final int maxItemsToShow;
  final bool expanded;
  final Widget Function(BuildContext, int) itemBuilder;

  const TranslationViewSpeechPartWrapper({
    Key? key,
    required this.name,
    required this.items,
    required this.maxItemsToShow,
    required this.expanded,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget categoryName;
    int itemsLength = items?.length ?? 0;

    if (name != null) {
      categoryName = Container(
        margin: const EdgeInsets.only(
          bottom: 5,
        ),
        child: Text(
          name!.capitalize(),
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
      margin: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: categoryName,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemsLength,
            itemBuilder: itemBuilder,
          ),
        ],
      ),
    );
  }
}
