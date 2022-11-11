import 'package:flutter/material.dart';

class ExpandButton extends StatelessWidget {
  final bool? expanded;
  final int? amount;
  final String? entity;
  final Function? onPressed;

  ExpandButton({ this.expanded, this.amount, this.entity, this.onPressed });

  @override
  Widget build(BuildContext context) {
    if (amount == null) {
      return Container();
    }

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size(0, 43),
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondaryContainer,
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
      ),
      child: Row( // Replace with a Row for horizontal icon + text
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Icon(
              expanded! ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).selectedRowColor,
              size: 25,
            ),
          ),
          Text(
            expanded!
              ? 'Show less $entity'
              : 'Show more $amount $entity',
            style: TextStyle(
              color: Theme.of(context).selectedRowColor,
              fontSize: 15,
            ),
          )
        ],
      ),
      onPressed: onPressed as void Function()?,
    );
  }
}
