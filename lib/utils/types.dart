import 'package:lingua_flutter/controllers/error_logger/error_logger.dart';

const undefined = Object();

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}

T? cast<T>(x) => x is T ? x : null;

List<dynamic>? getDynamicList(dynamic data) {
  List<dynamic>? result;
  try {
    result = data;
  } catch(error, stack) {
    recordError(error, stack);
  }
  return result;
}

String? getDynamicString(dynamic data) {
  String? result;
  try {
    result = data;
  } catch(error, stack) {
    recordError(error, stack);
  }
  return result;
}

int? getDynamicInt(dynamic data) {
  int? result;
  try {
    result = data;
  } catch(error, stack) {
    recordError(error, stack);
  }
  return result;
}