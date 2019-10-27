import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'package:lingua_flutter/app_config.dart' as appConfig;
import 'package:lingua_flutter/utils/api.dart';

String getApiUrl() {
  return '${appConfig.apiUrl}:${appConfig.apiPort}';
}

Future<Map<String, dynamic>> apiGet({
  @required http.Client client,
  @required String url,
  Map<String, String> params,
  Map<String, String> headers,
}) async {
  final uri = Uri.http(getApiUrl(), url, params);
  final response = await client.get(
    uri,
    headers: {
      HttpHeaders.authorizationHeader: appConfig.apiKey,
      ...?headers
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw ApiException(response.body);
  }
}
