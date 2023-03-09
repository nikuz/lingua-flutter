import 'dart:core';
import 'package:dio/dio.dart';
import 'package:lingua_flutter/models/error/error.dart';

export 'package:dio/dio.dart' show Options, ResponseType, CancelToken, DioError, Response;

enum RequestType {
  get,
  post,
  put,
  delete,
}

Future<Response<dynamic>> request({
  required RequestType method,
  required String url,
  Options? options,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? data,
  CancelToken? cancelToken,
}) async {
  late Response response;

  switch (method) {
    case RequestType.get:
      response = await Dio().get(
        url,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      break;

    case RequestType.post:
      response = await Dio().post(
        url,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        data: data,
      );
      break;

    case RequestType.put:
      response = await Dio().put(
        url,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        data: data,
      );
      break;

    case RequestType.delete:
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

Future<Response<dynamic>> get({
  required String url,
  Options? options,
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
}) => request(
  method: RequestType.get,
  url: url,
  options: options,
  queryParameters: queryParameters,
  cancelToken: cancelToken,
);

Future<Response<dynamic>> post({
  required String url,
  Options? options,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? data,
  CancelToken? cancelToken,
}) => request(
  method: RequestType.post,
  url: url,
  options: options,
  queryParameters: queryParameters,
  cancelToken: cancelToken,
  data: data,
);

Future<Response<dynamic>> put({
  required String url,
  Options? options,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? data,
  CancelToken? cancelToken,
}) => request(
  method: RequestType.put,
  url: url,
  options: options,
  queryParameters: queryParameters,
  cancelToken: cancelToken,
  data: data,
);

Future<Response<dynamic>> delete({
  required String url,
  Options? options,
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
}) => request(
  method: RequestType.delete,
  url: url,
  options: options,
  queryParameters: queryParameters,
  cancelToken: cancelToken,
);