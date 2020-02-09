import 'package:flutter/material.dart';

class GamesHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
