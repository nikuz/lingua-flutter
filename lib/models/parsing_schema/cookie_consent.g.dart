// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie_consent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookieConsentSchema _$CookieConsentSchemaFromJson(Map<String, dynamic> json) =>
    CookieConsentSchema(
      fields: CookieConsentSchemaFields.fromJson(
          json['fields'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CookieConsentSchemaToJson(
        CookieConsentSchema instance) =>
    <String, dynamic>{
      'fields': instance.fields.toJson(),
    };

CookieConsentSchemaFields _$CookieConsentSchemaFieldsFromJson(
        Map<String, dynamic> json) =>
    CookieConsentSchemaFields(
      marker: json['marker'] as String,
      formRegExp: json['formRegExp'] as String,
      inputRegExp: json['inputRegExp'] as String,
    );

Map<String, dynamic> _$CookieConsentSchemaFieldsToJson(
        CookieConsentSchemaFields instance) =>
    <String, dynamic>{
      'marker': instance.marker,
      'formRegExp': instance.formRegExp,
      'inputRegExp': instance.inputRegExp,
    };
