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
  final String? createdAt;
  final String? updatedAt;
  final String? version;

  const Translation({
    this.id,
    required this.word,
    required this.translation,
    this.pronunciation,
    this.image,
    required this.raw,
    this.schema,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  Translation copyWith({
    int? id,
    String? word,
    String? translation,
    String? pronunciation,
    String? image,
    List<dynamic>? raw,
    ParsingSchema? schema,
    String? createdAt,
    String? updatedAt,
    String? version,
  }) {
    return Translation(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      pronunciation: pronunciation ?? this.pronunciation,
      image: image ?? this.image,
      raw: raw ?? this.raw,
      schema: schema ?? this.schema,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }

  factory Translation.fromJson(Map<String, dynamic> json) => _$TranslationFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationToJson(this);
}
