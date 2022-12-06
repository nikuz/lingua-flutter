List<String> findAllJsonStrings(dynamic json, [List<String>? buffer]) {
  final strings = buffer ?? [];
  List<dynamic> values = [];

  if (json is Map) {
    values = json.values.toList();
  } else if (json is List) {
    values = json;
  } else {
    values = [json];
  }

  for (var item in values) {
    if (item is Map || item is List) {
      findAllJsonStrings(item, strings);
    } else if (item is String && item.contains('"')) {
      strings.add(item);
    }
  }

  // sort descending by length
  strings.sort((a, b) => b.length.compareTo(a.length));

  return strings;
}