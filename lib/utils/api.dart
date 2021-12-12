
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
