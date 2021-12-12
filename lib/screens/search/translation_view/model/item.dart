import 'package:equatable/equatable.dart';

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

  @override
  String toString() => '{ id: $id, word: $word, translation: $translation }';
}
