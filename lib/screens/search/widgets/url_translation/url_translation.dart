import 'package:flutter/material.dart';

import '../../search_state.dart';

class UrlTranslation extends StatelessWidget {
  const UrlTranslation({super.key});

  @override
  Widget build(BuildContext context) {
    final searchState = SearchInheritedState.of(context);

    return Container(
      margin: EdgeInsets.only(
        top: searchState?.getPaddingTop() ?? 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              constraints: const BoxConstraints(
                minHeight: 75,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'URL translation is not available',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}