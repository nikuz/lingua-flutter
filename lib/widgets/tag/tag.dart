import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final String text;

  const Tag({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 3,
        right: 8,
        bottom: 5,
        left: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          style: BorderStyle.solid,
          color: const Color.fromRGBO(218, 220, 224, 1),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(7)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}
