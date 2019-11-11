import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import 'package:lingua_flutter/utils/api.dart';

abstract class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object> get props => [];
}

class TranslationUninitialized extends TranslationState {}

class TranslationError extends TranslationState {
  final ApiException error;

  TranslationError([this.error]) : assert(error is ApiException);

  @override
  List<Object> get props => [error];

  @override
  String toString() => error.toString();
}

class TranslationRequestLoading extends TranslationState {}

class TranslationLoaded extends TranslationState {
  final int id;
  final String word;
  final String translation;
  final String pronunciation;
  final List<dynamic> raw;
  final String image;
  final String createdAt;

  TranslationLoaded({
    @required this.id,
    @required this.word,
    @required this.translation,
    @required this.pronunciation,
    @required this.raw,
    @required this.image,
    @required this.createdAt,
  }) : assert(word != null && raw != null);

  @override
  List<Object> get props => [id, word, translation, pronunciation, raw, image, createdAt];

  @override
  String toString() => '$word -> $translation';
}
