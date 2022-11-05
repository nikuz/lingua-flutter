import 'package:equatable/equatable.dart';

import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/providers/db.dart';

abstract class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object?> get props => [];

  get images => null;
  get imageLoading => null;
}

class TranslationUninitialized extends TranslationState {}

class TranslationError extends TranslationState {
  final error;

  TranslationError([this.error]) : assert(error is ApiException || error is DBException);

  @override
  List<Object?> get props => [error];

  @override
  String toString() => error.toString();
}

class TranslationRequestLoading extends TranslationState {}

class TranslationLoaded extends TranslationState {
  final int? id;
  final String? word;
  final String? translationWord;
  final String? translationOwn;
  final String? pronunciation;
  final List<dynamic>? highestRelevantTranslation;
  final String? transcription;
  final List<dynamic>? otherTranslations;
  final List<dynamic>? definitions;
  final List<dynamic>? definitionsSynonyms;
  final List<dynamic>? examples;
  final String? autoSpellingFix;
  final bool strangeWord;
  final String? image;
  final String? imageUrl;
  final bool? imageUpdate;
  final List<dynamic> images;
  final String? imageSearchWord;
  final bool imageLoading;
  final String? createdAt;
  final String? updatedAt;
  final bool? updateLoading;
  final bool? updateSuccess;
  final bool? saveLoading;
  final bool? saveSuccess;
  final List<dynamic>? raw;
  final bool? remote;
  final int? version;

  TranslationLoaded({
    required this.id,
    required this.word,
    required this.translationWord,
    this.translationOwn,
    required this.pronunciation,
    required this.image,
    this.imageUrl,
    required this.images,
    this.imageUpdate,
    required this.imageSearchWord,
    required this.imageLoading,
    required this.highestRelevantTranslation,
    required this.transcription,
    required this.otherTranslations,
    required this.definitions,
    required this.definitionsSynonyms,
    required this.examples,
    required this.autoSpellingFix,
    required this.strangeWord,
    required this.createdAt,
    required this.updatedAt,
    required this.raw,
    required this.remote,
    this.updateLoading,
    this.updateSuccess,
    this.saveLoading,
    this.saveSuccess,
    this.version,
  });

  TranslationLoaded copyWith({
    String? translationWord,
    String? translationOwn,
    List<dynamic>? images,
    bool? imageLoading,
    String? image,
    bool? imageUpdate,
    String? imageSearchWord,
    bool? updateLoading,
    bool? updateSuccess,
    bool? saveLoading,
    bool? saveSuccess,
  }) {
    return TranslationLoaded(
      id: this.id,
      word: this.word,
      translationWord: translationWord ?? this.translationWord,
      translationOwn: translationOwn ?? this.translationOwn,
      pronunciation: this.pronunciation,
      imageUrl: this.imageUrl == null ? this.image : this.imageUrl,
      image: image ?? (images != null && images.length != 0 ? images[0] : this.image),
      imageUpdate: imageUpdate ?? this.imageUpdate,
      imageLoading: imageLoading ?? this.imageLoading,
      images: images ?? this.images,
      imageSearchWord: imageSearchWord ?? this.imageSearchWord,
      highestRelevantTranslation: this.highestRelevantTranslation,
      transcription: this.transcription,
      otherTranslations: this.otherTranslations,
      definitions: this.definitions,
      definitionsSynonyms: this.definitionsSynonyms,
      examples: this.examples,
      autoSpellingFix: this.autoSpellingFix,
      strangeWord: this.strangeWord,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      updateLoading: updateLoading ?? this.updateLoading,
      updateSuccess: updateSuccess ?? this.updateSuccess,
      saveLoading: saveLoading ?? this.saveLoading,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      raw: this.raw,
      remote: this.remote,
      version: this.version,
    );
  }

  @override
  List<Object?> get props => [
    id,
    word,
    translationWord,
    translationOwn,
    pronunciation,
    image,
    imageUrl,
    imageUpdate,
    imageLoading,
    highestRelevantTranslation,
    transcription,
    otherTranslations,
    definitions,
    definitionsSynonyms,
    examples,
    autoSpellingFix,
    strangeWord,
    createdAt,
    updateLoading,
    updateSuccess,
    saveLoading,
    saveSuccess,
    raw,
    remote,
    version,
  ];

  @override
  String toString() => '$word -> $translationWord';
}
