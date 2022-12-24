import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

class EmptyDictionary extends StatelessWidget {
  const EmptyDictionary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (MediaQuery.of(context).size.height > 500)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Icon(
              Icons.menu_book_rounded,
              size: 100,
              color: Styles.colors.grey,
            ),
          ),

        const Text(
          'Dictionary is empty yet',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 350,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Text(
              'Start adding new words by searching them in the field above.',
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}