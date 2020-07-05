import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:lingua_flutter/helpers/api.dart';
import 'package:lingua_flutter/utils/api.dart';
import 'package:lingua_flutter/utils/files.dart';

Future<File> downloadFile(String url, String filename) async {
  http.Client _client = new http.Client();

  final Uri uri = Uri.http(apiUrl(), url);
  var req;
  try {
    req = await _client.get(uri);
  } catch (e) {
    throw ApiException(e);
  }
  var bytes = req.bodyBytes;

  String dir = await getDocumentsPath();
  File file = new File('$dir/$filename');
  await file.writeAsBytes(bytes);

  return file;
}
