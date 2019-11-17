import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

import './bloc/bloc.dart';
import './bloc/state.dart';

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
          int hiddenItemsAmount = 0;
          final List<dynamic> examples = state.examples[0];

          if (!expanded && examples.length > SHOW_MIN_EXAMPLES) {
            hiddenItemsAmount += examples.length - SHOW_MIN_EXAMPLES;
          }

          Widget expandButton = Container(width: 0, height: 0);

          if (expanded || hiddenItemsAmount > 0) {
            expandButton = FlatButton(
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
                      ? 'Show less examoples'
                      : 'Show more $hiddenItemsAmount examoples',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              },
            );
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
                      bottom: new Radius.circular(expandButton is FlatButton ? 0 : 8.0),
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
                expandButton,
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
