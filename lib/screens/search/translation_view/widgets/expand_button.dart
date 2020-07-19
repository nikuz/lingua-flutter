import 'package:flutter/material.dart';

import 'package:lingua_flutter/utils/sizes.dart';

class ExpandButton extends StatelessWidget {
  final bool expanded;
  final int amount;
  final String entity;
  final Function onPressed;

  ExpandButton({ this.expanded, this.amount, this.entity, this.onPressed });

  @override
  Widget build(BuildContext context) {
    if (amount == null) {
      return Container();
    }

    return FlatButton(
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.only(
          bottomLeft: Radius.circular(SizeUtil.vmax(8)),
          bottomRight: Radius.circular(SizeUtil.vmax(8)),
        ),
      ),
      padding: EdgeInsets.all(SizeUtil.vmax(3)),
      color: Theme.of(context).buttonTheme.colorScheme.secondaryVariant,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Row( // Replace with a Row for horizontal icon + text
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: SizeUtil.vmax(10)),
            child: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).selectedRowColor,
              size: SizeUtil.vmax(25),
            ),
          ),
          Text(
            expanded
              ? 'Show less $entity'
              : 'Show more $amount $entity',
            style: TextStyle(
              color: Theme.of(context).selectedRowColor,
              fontSize: SizeUtil.vmax(15),
            ),
          )
        ],
      ),
      onPressed: onPressed,
    );
  }
}
