import 'package:json_annotation/json_annotation.dart';

part 'cookie_consent.g.dart';

@JsonSerializable(explicitToJson: true)
class CookieConsentSchema {
  final CookieConsentSchemaFields fields;

  const CookieConsentSchema({
    required this.fields,
  });

  factory CookieConsentSchema.fromJson(Map<String, dynamic> json) => _$CookieConsentSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$CookieConsentSchemaToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CookieConsentSchemaFields {
  final String marker;
  final String formRegExp;
  final String inputRegExp;

  const CookieConsentSchemaFields({
    required this.marker,
    required this.formRegExp,
    required this.inputRegExp,
  });

  factory CookieConsentSchemaFields.fromJson(Map<String, dynamic> json) => _$CookieConsentSchemaFieldsFromJson(json);
  Map<String, dynamic> toJson() => _$CookieConsentSchemaFieldsToJson(this);
}