import 'dart:core';
import 'package:http/http.dart' as http;

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
    throw ApiException({
      'code': response.statusCode,
      'message': response.body,
    });
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
