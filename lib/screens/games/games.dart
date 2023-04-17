import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play a game'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Center(
              child: Text('Play a game'),
            ),
          ],
        ),
      ),
    );
  }
}
