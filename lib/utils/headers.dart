import 'package:dio/dio.dart' show Headers;

String? getHeaderRedirectLocation(Headers? headers) {
  final location = headers?['location'];
  if (location != null && location.isNotEmpty) {
    return location[0];
  }

  return null;
}