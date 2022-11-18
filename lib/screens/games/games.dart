import 'package:flutter/material.dart';

class Games extends StatelessWidget {
  Games({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text('Games page'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
