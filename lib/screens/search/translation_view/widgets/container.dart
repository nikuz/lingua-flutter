import 'package:flutter/material.dart';

import 'expand_button.dart';

class TranslationViewContainer extends StatefulWidget {
  final String? title;
  final String? entity;
  final Function? childBuilder;
  final int? itemsAmount;
  final int? maxItemsToShow;
  final bool? withBottomMargin;

  TranslationViewContainer({
    this.title,
    this.entity,
    this.childBuilder,
    this.itemsAmount,
    this.maxItemsToShow,
    this.withBottomMargin,
  }) : assert(title != null && entity != null && childBuilder != null && itemsAmount != null && maxItemsToShow != null);

  @override
  _TranslationViewContainerState createState() => _TranslationViewContainerState();
}

class _TranslationViewContainerState extends State<TranslationViewContainer> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    int? hiddenItemsAmount;

    if (widget.itemsAmount! > widget.maxItemsToShow!) {
      if (hiddenItemsAmount == null) {
        hiddenItemsAmount = 0;
      }
      if (!expanded) {
        hiddenItemsAmount += widget.itemsAmount! - widget.maxItemsToShow!;
      }
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: widget.withBottomMargin != null ? 10 : 0,
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
                style: BorderStyle.solid
              ),
              borderRadius: BorderRadius.vertical(
                top: new Radius.circular(8),
                bottom: new Radius.circular(hiddenItemsAmount != null ? 0 : 8),
              ),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '${widget.entity![0].toUpperCase()}${widget.entity!.substring(1)} of ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        widget.title!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                widget.childBuilder!(expanded),
              ],
            ),
          ),
          ExpandButton(
            amount: hiddenItemsAmount,
            entity: widget.entity,
            expanded: expanded,
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
          ),
        ],
      ),
    );
  }
}
