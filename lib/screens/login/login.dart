import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Center(
              child: Text('Login page'),
            )
          ],
        ),
      ),
    );
  }
}
