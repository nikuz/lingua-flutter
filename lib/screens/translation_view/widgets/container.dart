import 'package:flutter/material.dart';

import './expand_button.dart';

class TranslationViewContainer extends StatefulWidget {
  final String title;
  final String entity;
  final Function childBuilder;
  final int itemsLength;
  final int maxItemsToShow;
  final bool withBottomMargin;

  TranslationViewContainer({
    this.title,
    this.entity,
    this.childBuilder,
    this.itemsLength,
    this.maxItemsToShow,
    this.withBottomMargin,
  }) : assert(title != null && entity != null && childBuilder != null && itemsLength != null && maxItemsToShow != null);

  @override
  _TranslationViewContainerState createState() => _TranslationViewContainerState();
}

class _TranslationViewContainerState extends State<TranslationViewContainer> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    int hiddenItemsAmount;

    if (widget.itemsLength > widget.maxItemsToShow) {
      if (hiddenItemsAmount == null) {
        hiddenItemsAmount = 0;
      }
      if (!expanded) {
        hiddenItemsAmount += widget.itemsLength - widget.maxItemsToShow;
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
                color: Color.fromRGBO(218, 220, 224, 1),
                width: 1.0,
                style: BorderStyle.solid
              ),
              borderRadius: BorderRadius.vertical(
                top: new Radius.circular(8.0),
                bottom: new Radius.circular(hiddenItemsAmount != null ? 0 : 8.0),
              ),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '${widget.entity[0].toUpperCase()}${widget.entity.substring(1)} of ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(119, 119, 119, 1),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(34, 34, 34, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                widget.childBuilder(expanded),
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
