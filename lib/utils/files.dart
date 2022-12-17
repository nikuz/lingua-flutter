import 'package:path_provider/path_provider.dart';

Future<String> getDocumentsPath() async {
  String documentsPath = (await getApplicationDocumentsDirectory()).path;
  if (!documentsPath.endsWith('/')) {
    documentsPath += '/';
  }
  return documentsPath;
}

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
