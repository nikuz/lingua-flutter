import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      autocorrect: false,
      onChanged: (text) {
        print(text);
//        _githubSearchBloc.add(
//          TextChanged(text: text),
//        );
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon: GestureDetector(
          child: Icon(Icons.clear),
          onTap: _onClearTapped,
        ),
//        border: InputBorder.none,
        hintText: 'Search word',
      ),
    );
  }

  void _onClearTapped() {
    _textController.text = '';
//    _githubSearchBloc.add(TextChanged(text: ''));
  }
}
