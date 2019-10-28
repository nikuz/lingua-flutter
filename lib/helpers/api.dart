import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'package:lingua_flutter/app_config.dart' as appConfig;
import 'package:lingua_flutter/utils/api.dart';

String apiUrl = '${appConfig.apiUrl}:${appConfig.apiPort}';

String getApiUri() {
  return Uri.http(apiUrl, '').toString();
}

Future<Map<String, dynamic>> apiGet({
  @required http.Client client,
  @required String url,
  Map<String, String> params,
  Map<String, String> headers,
}) async {
  final uri = Uri.http(apiUrl, url, params);
  final response = await client.get(
    uri,
    headers: {
      HttpHeaders.authorizationHeader: appConfig.apiKey,
      ...?headers
    },
  );

  final body = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return body;
  } else {
    throw ApiException(body);
  }
}
