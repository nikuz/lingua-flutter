import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:lingua_flutter/models/error.dart';

Future<String> apiRequest({
  required String method,
  required String url,
  Map<String, String>? params,
  Map<String, String>? headers,
}) async {
  late http.Response response;

  if (method == 'get') {
    response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
  } else if (method == 'post') {
    response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: params,
    );
  } else if (method == 'put') {
    response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: params,
    );
  } else if (method == 'delete') {
    response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );
  }

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw CustomError(
      code: response.statusCode,
      message: response.body,
    );
  }
}

Future<String> apiGet({
  required String url,
  Map<String, String>? params,
  Map<String, String>? headers,
}) async {
  Future<String> response = apiRequest(
    method: 'get',
    url: url,
    params: params,
    headers: headers,
  );

  return response;
}

Future<String> apiPost({
  required String url,
  Map<String, String>? params,
  Map<String, String>? headers,
}) async {
  Future<String> response = apiRequest(
    method: 'post',
    url: url,
    params: params,
    headers: headers,
  );

  return response;
}

Future<String> apiPut({
  required String url,
  Map<String, String>? params,
  Map<String, String>? headers,
}) async {
  Future<String> response = apiRequest(
    method: 'put',
    url: url,
    params: params,
    headers: headers,
  );

  return response;
}

Future<String> apiDelete({
  required String url,
  Map<String, String>? params,
  Map<String, String>? headers,
}) async {
  Future<String> response = apiRequest(
    method: 'delete',
    url: url,
    params: params,
    headers: headers,
  );

  return response;
}