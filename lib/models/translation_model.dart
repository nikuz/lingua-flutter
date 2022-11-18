import 'package:json_annotation/json_annotation.dart';

part 'translation_model.g.dart';

@JsonSerializable()
class Translation {
  final int? id;
  final String? word;
  final String? translation;
  final String? pronunciation;
  final String? image;
  final List<dynamic>? raw;
  final String? createdAt;
  final String? updatedAt;
  final bool? remote;
  final int? version;

  const Translation({
    this.id,
    this.word,
    this.translation,
    this.pronunciation,
    this.image,
    this.raw,
    this.createdAt,
    this.updatedAt,
    this.remote,
    this.version,
  });

  factory Translation.fromJson(Map<String, dynamic> json) => _$TranslationFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationToJson(this);
}
