import 'dart:convert';

class ApiResponse {
  final String body;

  ApiResponse([this.body]) : assert(body != null);

  List<Object> get props => [body];
}

class ApiException implements Exception {
  int code;
  String message;

  ApiException(String apiResponse) {
    final errorBody = jsonDecode(apiResponse);
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

  List<Object> get props => [code, message];

  @override
  String toString() {
    return '$code: $message';
  }
}
