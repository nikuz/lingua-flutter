import 'package:flutter/material.dart';

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
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
      ),
      color: Color.fromRGBO(26, 88, 136, 1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Row( // Replace with a Row for horizontal icon + text
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
          ),
          Text(
            expanded
              ? 'Show less $entity'
              : 'Show more $amount $entity',
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
      onPressed: onPressed,
    );
  }
}
