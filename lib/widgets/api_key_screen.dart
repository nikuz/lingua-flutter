import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_flutter/utils/sizes.dart';

import 'package:lingua_flutter/app_config.dart' as appConfig;

class ApiKeyScreen extends StatefulWidget {
  final Function callback;

  ApiKeyScreen(this.callback);

  @override
  _ApiKeyScreenState createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(
          left: SizeUtil.vmax(20),
          right: SizeUtil.vmax(20),
        ),
        child: Center(
          child: TextField(
            controller: _textController,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (String value) async {
              if (value.length > 1) {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('apiKey', value);
                appConfig.apiKey = value;
                widget.callback();
              }
            },
            decoration: InputDecoration(
              hintText: 'Type API key',
              hintStyle: TextStyle(
                fontSize: SizeUtil.vmax(20),
              ),
            ),
            style: TextStyle(
                fontSize: SizeUtil.vmax(20),
                color: Colors.black
            ),
          ),
        ),
      ),
    );;
  }
}
