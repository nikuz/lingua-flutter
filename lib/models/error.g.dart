// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomError _$CustomErrorFromJson(Map<String, dynamic> json) => CustomError(
      code: json['code'] as int,
      message: json['message'] as String,
    );

Map<String, dynamic> _$CustomErrorToJson(CustomError instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };
