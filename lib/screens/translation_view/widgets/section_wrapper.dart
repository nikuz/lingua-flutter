import 'package:flutter/material.dart';
import 'package:lingua_flutter/utils/string.dart';

class TranslationViewSectionWrapper extends StatefulWidget {
  final String name;
  final String? word;
  final int itemsAmount;
  final int maxItemsToShow;
  final bool withBottomMargin;
  final Function childBuilder;

  const TranslationViewSectionWrapper({
    Key? key,
    required this.name,
    this.word,
    required this.itemsAmount,
    required this.maxItemsToShow,
    this.withBottomMargin = false,
    required this.childBuilder,
  }) : super(key: key);

  @override
  State<TranslationViewSectionWrapper> createState() => _TranslationViewSectionWrapperState();
}

class _TranslationViewSectionWrapperState extends State<TranslationViewSectionWrapper> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    int? hiddenItemsAmount;

    if (widget.itemsAmount > widget.maxItemsToShow) {
      if (!expanded) {
        hiddenItemsAmount = widget.itemsAmount - widget.maxItemsToShow;
      }
    }

    return Container(
      margin: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: widget.withBottomMargin ? 10 : 0,
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                  style: BorderStyle.solid
              ),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(8),
                bottom: Radius.circular(hiddenItemsAmount != null ? 0 : 8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Wrap(
                  direction: Axis.horizontal,
                  children: [
                    Text(
                      '${widget.name.capitalize()} of ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    Text(
                      widget.word ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                widget.childBuilder(expanded),
              ],
            ),
          ),
          TranslationViewSectionWrapperExpandButton(
            amount: hiddenItemsAmount,
            name: widget.name,
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

class TranslationViewSectionWrapperExpandButton extends StatelessWidget {
  final bool expanded;
  final String name;
  final int? amount;
  final VoidCallback? onPressed;

  const TranslationViewSectionWrapperExpandButton({
    Key? key,
    required this.expanded,
    required this.name,
    this.amount,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (amount == null) {
      return Container();
    }

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 43),
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondaryContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Row( // Replace with a Row for horizontal icon + text
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).selectedRowColor,
              size: 25,
            ),
          ),
          Text(
            expanded
                ? 'Show less $name'
                : 'Show more $amount $name',
            style: TextStyle(
              color: Theme.of(context).selectedRowColor,
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }
}
