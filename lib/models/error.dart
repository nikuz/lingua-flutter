import 'package:json_annotation/json_annotation.dart';

part 'error.g.dart';

@JsonSerializable()
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

  factory CustomError.fromJson(Map<String, dynamic> json) => _$CustomErrorFromJson(json);
  Map<String, dynamic> toJson() => _$CustomErrorToJson(this);
}
