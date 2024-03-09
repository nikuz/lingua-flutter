import 'package:flutter/material.dart';
import 'package:lingua_flutter/widgets/typography/typography.dart';

import '../../search_constants.dart';

class EmptySearch extends StatelessWidget {
  final bool hasInternetConnection;

  const EmptySearch({
    super.key,
    required this.hasInternetConnection,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: SearchConstants.searchFieldHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!hasInternetConnection && MediaQuery.of(context).size.height > 500)
                const Image(
                  image: AssetImage('assets/images/no_internet.png'),
                  width: 200,
                  height: 200,
                ),

              if (!hasInternetConnection)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: const TypographyText(
                    text: 'You are offline',
                    margin: EdgeInsets.zero,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),

              const Center(
                child: SizedBox(
                  width: 350,
                  child: TypographyText(
                    text: 'And no words stored on your device are matching the search request',
                    align: TextAlign.center,
                    margin: EdgeInsets.zero,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}