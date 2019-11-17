import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

import './bloc/bloc.dart';
import './bloc/state.dart';
import './widgets/expand_button.dart';

const SHOW_MIN_EXAMPLES = 1;

class Examples extends StatefulWidget {
  @override
  _ExamplesState createState() => _ExamplesState();
}

class _ExamplesState extends State<Examples> {
  bool expanded = false;
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        if (state is TranslationLoaded && state.examples != null) {
          int hiddenItemsAmount;
          final List<dynamic> examples = state.examples[0];

          if (examples.length > SHOW_MIN_EXAMPLES) {
            if (hiddenItemsAmount == null) {
              hiddenItemsAmount = 0;
            }
            if (!expanded) {
              hiddenItemsAmount += examples.length - SHOW_MIN_EXAMPLES;
            }
          }

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
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
                            'Examples of ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(119, 119, 119, 1),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(
                              state.word,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(34, 34, 34, 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return ExamplesItem(
                            item: examples[index],
                          );
                        },
                        itemCount: examples.length - hiddenItemsAmount,
                      ),
                    ],
                  ),
                ),
                ExpandButton(
                  amount: hiddenItemsAmount,
                  entity: 'examples',
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

        return Container();
      }
    );
  }
}


class ExamplesItem extends StatelessWidget {
  final List<dynamic> item;

  ExamplesItem({
    Key key,
    @required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String text = item[0];

    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.format_quote,
            size: 20,
            color: Color.fromRGBO(119, 119, 119, 1),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            margin: EdgeInsets.only(left: 20),
            child: Html(
              data: """$text""",
              defaultTextStyle: TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(0, 0, 0, 0.89),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
