import 'package:path_provider/path_provider.dart';

Future<String> getDocumentsPath() async => (
    (await getApplicationDocumentsDirectory()).path
);

Future<String> getTempPath() async => (
    (await getTemporaryDirectory()).path
);

String generateFileIdFromWord(int id, String word) {
  final String sanitisedWord = word
      .split(' ')
      .map((part) => (part.trim().replaceAll(RegExp(r'[^A-Za-z0-9]'), '')))
      .join('-')
      .toLowerCase();

  return '$id-$sanitisedWord';
}
