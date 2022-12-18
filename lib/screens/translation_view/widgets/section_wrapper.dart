import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/utils/string.dart';

const double buttonHeight = 40;

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
  final buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    int? hiddenItemsAmount;

    if (widget.itemsAmount > widget.maxItemsToShow) {
      hiddenItemsAmount ??= 0;
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
      child: Stack(
        children: [
          Container(
            margin: hiddenItemsAmount != null
                ? const EdgeInsets.only(bottom: buttonHeight - 1)
                : null,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(8),
                bottom: Radius.circular(hiddenItemsAmount != null ? 0 : 8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Wrap(
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
                ),

                widget.childBuilder(expanded),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TranslationViewSectionWrapperExpandButton(
              key: buttonKey,
              amount: hiddenItemsAmount,
              name: widget.name,
              expanded: expanded,
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
                if (buttonKey.currentContext != null) {
                  WidgetsBinding.instance.addPostFrameCallback((dynamic) {
                    Scrollable.ensureVisible(
                      buttonKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      alignment: 1,
                    );
                  });
                }
              },
            ),
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
  final VoidCallback onPressed;

  const TranslationViewSectionWrapperExpandButton({
    Key? key,
    required this.expanded,
    required this.name,
    this.amount,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (amount == null) {
      return Container();
    }

    final MyTheme theme = Styles.theme(context);
    BorderRadius borderRadius = const BorderRadius.vertical(
      top: Radius.circular(0),
      bottom: Radius.circular(8),
    );

    return Material(
      color: theme.colors.focusBackground,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onPressed,
        child: Container(
          height: buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
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
        ),
      ),
    );
  }
}
