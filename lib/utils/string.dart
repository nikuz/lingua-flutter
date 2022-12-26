extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

String findLongestStringInList(List<String> strings) {
  String longestString = '';

  for (String item in strings) {
    if (item.length > longestString.length) {
      longestString = item;
    }
  }

  return longestString;
}

String removeSlashFromString(String value) {
  return value.replaceAll('\\', '');
}

String removeQuotesFromString(String value) {
  return value.replaceAll('\'', '').replaceAll('"', '');
}