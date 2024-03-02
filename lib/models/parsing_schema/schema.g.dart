// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParsingSchema _$ParsingSchemaFromJson(Map<String, dynamic> json) =>
    ParsingSchema(
      cookieConsent: CookieConsentSchema.fromJson(
          json['cookieConsent'] as Map<String, dynamic>),
      quickTranslation: QuickTranslationSchema.fromJson(
          json['quickTranslation'] as Map<String, dynamic>),
      translation: TranslationSchema.fromJson(
          json['translation'] as Map<String, dynamic>),
      pronunciation: PronunciationSchema.fromJson(
          json['pronunciation'] as Map<String, dynamic>),
      images: ImagesSchema.fromJson(json['images'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ParsingSchemaToJson(ParsingSchema instance) =>
    <String, dynamic>{
      'cookieConsent': instance.cookieConsent.toJson(),
      'quickTranslation': instance.quickTranslation.toJson(),
      'translation': instance.translation.toJson(),
      'pronunciation': instance.pronunciation.toJson(),
      'images': instance.images.toJson(),
    };
