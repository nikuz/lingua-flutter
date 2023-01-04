import 'package:flutter/material.dart';

import '../../search_constants.dart';

class EmptyDictionary extends StatelessWidget {
  const EmptyDictionary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: SearchConstants.searchFieldHeight),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (MediaQuery.of(context).size.height > 500)
            const Image(image: AssetImage('assets/images/tree.png')),

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
      ),
    );
  }
}