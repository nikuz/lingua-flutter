import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';
import 'package:lingua_flutter/utils/string.dart';

const double buttonHeight = 40;

class TranslationViewSectionWrapper extends StatefulWidget {
  final String name;
  final String? word;
  final int itemsAmount;
  final int maxItemsToShow;
  final EdgeInsets? padding;
  final Function childBuilder;

  const TranslationViewSectionWrapper({
    Key? key,
    required this.name,
    this.word,
    required this.itemsAmount,
    required this.maxItemsToShow,
    this.padding,
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
    final MyTheme theme = Styles.theme(context);
    int? hiddenItemsAmount;

    if (widget.itemsAmount > widget.maxItemsToShow) {
      hiddenItemsAmount ??= 0;
      if (!expanded) {
        hiddenItemsAmount = widget.itemsAmount - widget.maxItemsToShow;
      }
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Stack(
            children: [
              Container(
                margin: hiddenItemsAmount != null
                    ? const EdgeInsets.only(bottom: buttonHeight - 1)
                    : null,
                padding: widget.padding,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colors.divider,
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colors.primary.withOpacity(0.6),
                          ),
                          children: [
                            TextSpan(text: '${widget.name.capitalize()} of '),
                            TextSpan(text: widget.word ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
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
        ),

        SizedBox(
          key: buttonKey,
          height: 10,
        ),
      ],
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
                  color: Styles.colors.white.withOpacity(0.9),
                  size: 25,
                ),
              ),
              Text(
                expanded
                    ? 'Show less $name'
                    : 'Show more $amount $name',
                style: TextStyle(
                  color: Styles.colors.white.withOpacity(0.9),
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
