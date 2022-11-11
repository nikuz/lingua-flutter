import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'translation.model.g.dart';

@JsonSerializable()
class Translation extends Equatable {
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

  // final int? id;
  // final String? word;
  // final String? translation;
  // final String? pronunciation;
  // final String? image;
  // final String? imageUrl;
  // final String? createdAt;
  // final String updatedAt;

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

  @override
  List<Object?> get props => [
    id,
    word,
    translation,
    pronunciation,
    image,
    raw,
    createdAt,
    updatedAt,
    remote,
    version,
  ];

  factory Translation.fromJson(Map<String, dynamic> json) => _$TranslationFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationToJson(this);

  @override
  String toString() => '{ id: $id, word: $word, translation: $translation }';
}
