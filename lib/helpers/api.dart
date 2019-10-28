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

Future<Map<String, dynamic>> apiRequest({
  @required String method,
  @required http.Client client,
  @required String url,
  Map<String, String> params,
  Map<String, String> headers,
}) async {
  final uri = Uri.http(apiUrl, url, params);
  final headersProps = {
    HttpHeaders.authorizationHeader: appConfig.apiKey,
    ...?headers
  };

  http.Response response;

  if (method == 'get') {
    response = await client.get(
      uri,
      headers: headersProps,
    );

  } else if (method == 'delete') {
    response = await client.delete(
      uri,
      headers: headersProps,
    );
  }

  final body = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return body;
  } else {
    throw ApiException(body);
  }
}

Future<Map<String, dynamic>> apiGet({
  @required http.Client client,
  @required String url,
  Map<String, String> params,
  Map<String, String> headers,
  String method,
}) async {
  Future<Map<String, dynamic>> response = apiRequest(
    method: 'get',
    client: client,
    url: url,
    params: params,
  );

  return response;
}

Future<Map<String, dynamic>> apiDelete({
  @required http.Client client,
  @required String url,
  Map<String, String> params,
  Map<String, String> headers,
}) async {
  Future<Map<String, dynamic>> response = apiRequest(
      method: 'delete',
      client: client,
      url: url,
      params: params,
  );

  return response;
}
