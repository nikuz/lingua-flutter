import 'package:json_annotation/json_annotation.dart';
import './parsing_schema/schema.dart';

part 'translation.g.dart';

@JsonSerializable()
class Translation {
  final int? id;
  final String word;
  final String? translation;
  final String? pronunciation;
  final String? image;
  final List<dynamic> raw;
  final ParsingSchema? schema;
  final String? schemaVersion;
  final String? createdAt;
  final String? updatedAt;

  const Translation({
    this.id,
    required this.word,
    required this.translation,
    this.pronunciation,
    this.image,
    required this.raw,
    this.schema,
    this.schemaVersion,
    this.createdAt,
    this.updatedAt,
  });

  Translation copyWith({
    int? id,
    String? word,
    String? translation,
    String? pronunciation,
    String? image,
    List<dynamic>? raw,
    ParsingSchema? schema,
    String? schemaVersion,
    String? createdAt,
    String? updatedAt,
  }) {
    return Translation(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      pronunciation: pronunciation ?? this.pronunciation,
      image: image ?? this.image,
      raw: raw ?? this.raw,
      schema: schema ?? this.schema,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Translation.fromJson(Map<String, dynamic> json) => _$TranslationFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationToJson(this);
}
