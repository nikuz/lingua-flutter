import 'package:flutter/material.dart';
import 'package:lingua_flutter/utils/sizes.dart';

class GamesHomePage extends StatelessWidget {
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
                padding: EdgeInsets.all(SizeUtil.vmax(10)),
                child: Text('Games page'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
