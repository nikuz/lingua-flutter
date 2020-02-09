import 'package:flutter/material.dart';

Future<bool> wordRemovePrompt(context, String word, Function callback) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm'),
        content: Text('Are you sure you wish to delete "$word" word?'),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                callback();
              },
              child: const Text("DELETE")
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("CANCEL"),
          ),
        ],
      );
    },
  );
}
