import 'package:flutter/material.dart';

Future<bool> prompt({
  context,
  title,
  text,
  withCancel,
  Function acceptCallback,
  Function cancelCallback,
  Function closeCallback,
}) async {
  List<Widget> actions = <Widget>[
    FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(true);
        acceptCallback();
      },
      child: Text("OK")
    ),
  ];

  if (withCancel == true) {
    actions.add(
      FlatButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop(false);
          if (cancelCallback is Function) {
            cancelCallback();
          }
        },
        child: Text("CANCEL"),
      )
    );
  }

  return await showDialog(
    context: context,
    builder: (BuildContext context) => (
      AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: actions,
      )
    ),
  ).then((val) {
    if (closeCallback is Function) {
      closeCallback();
    }
    return val;
  });
}

Future<bool> wordRemovePrompt(context, String word, Function callback) async {
  return prompt(
    context: context,
    title: 'Confirm',
    text: 'Are you sure you wish to delete "$word" word?',
    withCancel: true,
    acceptCallback: callback,
  );
}
