import 'package:path_provider/path_provider.dart';

Future<String> getDocumentsPath() async => (
    (await getApplicationDocumentsDirectory()).path
);

Future<String> getTempPath() async => (
    (await getTemporaryDirectory()).path
);

String getFileId(int id, String word) {
  word.trim().replaceAll(new RegExp(r'[\s|/.,]'), '-');
  final String cleanedWord = word
      .split(' ')
      .map((part) => (part.trim().replaceAll(new RegExp(r'[^A-Za-z0-9]'), '')))
      .join('-')
      .toLowerCase();

  if (cleanedWord.length == 0) {
    return '';
  }

  return '$id-$cleanedWord';
}
