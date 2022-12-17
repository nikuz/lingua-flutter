import 'package:flutter/material.dart';
import 'package:lingua_flutter/styles/styles.dart';

class EmptySearch extends StatelessWidget {
  final bool hasInternetConnection;

  const EmptySearch({
    Key? key,
    required this.hasInternetConnection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!hasInternetConnection)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Icon(
              Icons.signal_wifi_connected_no_internet_4,
              size: 100,
              color: Styles.colors.grey,
            ),
          ),

        if (!hasInternetConnection)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: const Text(
              'No internet connection',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),

        const Center(
          child: Text('No translations found in your dictionary'),
        ),
      ],
    );
  }
}