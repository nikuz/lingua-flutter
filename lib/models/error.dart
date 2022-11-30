class CustomError implements Exception {
  final int code;
  final String message;

  const CustomError({
    required this.code,
    required this.message,
  });

  List<Object?> get props => [code, message];

  @override
  String toString() {
    return '$code: $message';
  }
}
