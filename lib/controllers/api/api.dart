import 'dart:core';
import 'package:dio/dio.dart';
import 'package:lingua_flutter/models/error/error.dart';

export 'package:dio/dio.dart' show Options, ResponseType, CancelToken, DioError, Response;

enum ApiRequestType {
  get,
  post,
  put,
  delete,
}

Future<Response<dynamic>> apiRequest({
  required ApiRequestType method,
  required String url,
  Options? options,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? data,
  CancelToken? cancelToken,
}) async {
  late Response response;

  switch (method) {
    case ApiRequestType.get:
      response = await Dio().get(
        url,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      break;

    case ApiRequestType.post:
      response = await Dio().post(
        url,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        data: data,
      );
      break;

    case ApiRequestType.put:
      response = await Dio().put(
        url,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        data: data,
      );
      break;

    case ApiRequestType.delete:
      response = await Dio().delete(
        url,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      break;
  }

  if (response.statusCode != null && response.statusCode! < 400) {
    return response;
  } else {
    throw CustomError(
      code: response.statusCode ?? 0,
      message: response.data,
    );
  }
}

Future<Response<dynamic>> apiGet({
  required String url,
  Options? options,
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
}) => apiRequest(
  method: ApiRequestType.get,
  url: url,
  options: options,
  queryParameters: queryParameters,
  cancelToken: cancelToken,
);

Future<Response<dynamic>> apiPost({
  required String url,
  Options? options,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? data,
  CancelToken? cancelToken,
}) => apiRequest(
  method: ApiRequestType.post,
  url: url,
  options: options,
  queryParameters: queryParameters,
  cancelToken: cancelToken,
  data: data,
);

Future<Response<dynamic>> apiPut({
  required String url,
  Options? options,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? data,
  CancelToken? cancelToken,
}) => apiRequest(
  method: ApiRequestType.put,
  url: url,
  options: options,
  queryParameters: queryParameters,
  cancelToken: cancelToken,
  data: data,
);

Future<Response<dynamic>> apiDelete({
  required String url,
  Options? options,
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
}) => apiRequest(
  method: ApiRequestType.delete,
  url: url,
  options: options,
  queryParameters: queryParameters,
  cancelToken: cancelToken,
);