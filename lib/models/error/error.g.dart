// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomError _$CustomErrorFromJson(Map<String, dynamic> json) => CustomError(
      message: json['message'] as String,
      code: (json['code'] as num?)?.toInt(),
      information: (json['information'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as Object),
      ),
    );

Map<String, dynamic> _$CustomErrorToJson(CustomError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'information': instance.information,
    };
