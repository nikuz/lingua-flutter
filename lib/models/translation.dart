import 'package:json_annotation/json_annotation.dart';
import './parsing_schema/schema.dart';

part 'translation.g.dart';

@JsonSerializable()
class Translation {
  final int? id;
  final String word;
  final String translation;
  final String? pronunciation;
  final String? image;
  final List<dynamic> raw;
  ParsingSchema? schema;
  final String? createdAt;
  final String? updatedAt;
  final bool? remote;
  final String? version;

  Translation({
    this.id,
    required this.word,
    required this.translation,
    this.pronunciation,
    this.image,
    required this.raw,
    this.schema,
    this.createdAt,
    this.updatedAt,
    this.remote,
    this.version,
  });

  factory Translation.fromJson(Map<String, dynamic> json) => _$TranslationFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationToJson(this);
}
