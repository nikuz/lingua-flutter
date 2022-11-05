import 'dart:core';
import 'package:http/http.dart' as http;

Future<String> apiRequest({
  required String method,
  required http.Client client,
  required String url,
  Map<String, String>? params,
  Map<String, String>? headers,
}) async {
  late http.Response response;

  if (method == 'get') {
    response = await client.get(
      Uri.parse(url),
      headers: headers,
    );
  } else if (method == 'post') {
    response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: params,
    );
  } else if (method == 'put') {
    response = await client.put(
      Uri.parse(url),
      headers: headers,
      body: params,
    );
  } else if (method == 'delete') {
    response = await client.delete(
      Uri.parse(url),
      headers: headers,
    );
  }

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw ApiException({
      'code': response.statusCode,
      'message': response.body,
    });
  }
}

Future<String> apiGet({
  required http.Client client,
  required String url,
  Map<String, String>? params,
  Map<String, String>? headers,
}) async {
  Future<String> response = apiRequest(
    method: 'get',
    client: client,
    url: url,
    params: params,
    headers: headers,
  );

  return response;
}

Future<String> apiPost({
  required http.Client client,
  required String url,
  Map<String, String>? params,
  Map<String, String>? headers,
}) async {
  Future<String> response = apiRequest(
    method: 'post',
    client: client,
    url: url,
    params: params,
    headers: headers,
  );

  return response;
}

Future<String> apiPut({
  required http.Client client,
  required String url,
  Map<String, String>? params,
  Map<String, String>? headers,
}) async {
  Future<String> response = apiRequest(
    method: 'put',
    client: client,
    url: url,
    params: params,
    headers: headers,
  );

  return response;
}

Future<String> apiDelete({
  required http.Client client,
  required String url,
  Map<String, String>? params,
  Map<String, String>? headers,
}) async {
  Future<String> response = apiRequest(
    method: 'delete',
    client: client,
    url: url,
    params: params,
    headers: headers,
  );

  return response;
}

class ApiException implements Exception {
  int? code;
  String? message;

  ApiException(Map<String, dynamic> errorBody) {
    final errorCode = errorBody['error'];
    final errorMessage = errorBody['message'];

    this.code = errorCode is int ? errorCode : 0;

    if (errorMessage is List) {
      this.message = errorMessage[0];
    } else if (errorMessage is String) {
      this.message = errorMessage;
    } else {
      this.message = 'ApiExceptionError';
    }
  }

  List<Object?> get props => [code, message];

  @override
  String toString() {
    return '$code: $message';
  }
}
