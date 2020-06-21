import 'package:flutter/material.dart';

import 'package:lingua_flutter/utils/sizes.dart';

import 'expand_button.dart';

class TranslationViewContainer extends StatefulWidget {
  final String title;
  final String entity;
  final Function childBuilder;
  final int itemsAmount;
  final int maxItemsToShow;
  final bool withBottomMargin;

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
    int hiddenItemsAmount;

    if (widget.itemsAmount > widget.maxItemsToShow) {
      if (hiddenItemsAmount == null) {
        hiddenItemsAmount = 0;
      }
      if (!expanded) {
        hiddenItemsAmount += widget.itemsAmount - widget.maxItemsToShow;
      }
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: SizeUtil.vmax(10),
        left: SizeUtil.vmax(10),
        right: SizeUtil.vmax(10),
        bottom: widget.withBottomMargin != null ? SizeUtil.vmax(10) : 0,
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(SizeUtil.vmax(10)),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(218, 220, 224, 1),
                width: SizeUtil.vmax(1),
                style: BorderStyle.solid
              ),
              borderRadius: BorderRadius.vertical(
                top: new Radius.circular(SizeUtil.vmax(8)),
                bottom: new Radius.circular(hiddenItemsAmount != null ? 0 : SizeUtil.vmax(8)),
              ),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '${widget.entity[0].toUpperCase()}${widget.entity.substring(1)} of ',
                      style: TextStyle(
                        fontSize: SizeUtil.vmax(16),
                        color: Color.fromRGBO(119, 119, 119, 1),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: SizeUtil.vmax(5)),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: SizeUtil.vmax(16),
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
