// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Translation _$TranslationFromJson(Map<String, dynamic> json) => Translation(
      id: json['id'] as int?,
      word: json['word'] as String?,
      translation: json['translation'] as String?,
      pronunciation: json['pronunciation'] as String?,
      image: json['image'] as String?,
      raw: json['raw'] as List<dynamic>?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      remote: json['remote'] as bool?,
      version: json['version'] as int?,
    );

Map<String, dynamic> _$TranslationToJson(Translation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'translation': instance.translation,
      'pronunciation': instance.pronunciation,
      'image': instance.image,
      'raw': instance.raw,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'remote': instance.remote,
      'version': instance.version,
    };
