import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/providers/db.dart';
import 'package:lingua_flutter/utils/types.dart';

import '../models/translation.model.dart';

part 'translation_view_state.g.dart';

@JsonSerializable()
class TranslationViewState extends Equatable {
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
  final bool imageUpdated;
  final List<dynamic> images;
  final String? imageSearchWord;
  final bool translateLoading;
  final bool imageLoading;
  final String? createdAt;
  final String? updatedAt;
  final bool? saveLoading;
  final Translation? savedTranslation;
  final bool? updateLoading;
  final Translation? updatedTranslation;
  final List<dynamic>? raw;
  final bool? remote;
  final int? version;
  final error;

  const TranslationViewState({
    this.id,
    this.word,
    this.translationWord,
    this.translationOwn,
    this.pronunciation,
    this.image,
    this.imageUrl,
    this.images = const [],
    this.imageUpdated = false,
    this.imageSearchWord,
    this.translateLoading = false,
    this.imageLoading = false,
    this.highestRelevantTranslation,
    this.transcription,
    this.otherTranslations,
    this.definitions,
    this.definitionsSynonyms,
    this.examples,
    this.autoSpellingFix,
    this.strangeWord = false,
    this.createdAt,
    this.updatedAt,
    this.raw,
    this.remote,
    this.saveLoading,
    this.savedTranslation,
    this.updateLoading,
    this.updatedTranslation,
    this.version,
    this.error,
  }) : assert(error is ApiException || error is DBException || error == null);

  TranslationViewState copyWith({
    int? id,
    String? word,
    String? translationWord,
    String? translationOwn,
    String? pronunciation,
    List<dynamic>? highestRelevantTranslation,
    String? transcription,
    List<dynamic>? otherTranslations,
    List<dynamic>? definitions,
    List<dynamic>? definitionsSynonyms,
    List<dynamic>? examples,
    String? autoSpellingFix,
    bool? strangeWord,
    String? image,
    String? imageUrl,
    bool? imageUpdated,
    List<dynamic>? images,
    String? imageSearchWord,
    bool? translateLoading,
    bool? imageLoading,
    String? createdAt,
    String? updatedAt,
    bool? saveLoading,
    Translation? savedTranslation,
    bool? updateLoading,
    Translation? updatedTranslation,
    List<dynamic>? raw,
    bool? remote,
    int? version,
    Wrapped? error,
  }) {
    return TranslationViewState(
      id: id ?? this.id,
      word: word ?? this.word,
      translationWord: translationWord ?? this.translationWord,
      translationOwn: translationOwn ?? this.translationOwn,
      pronunciation: pronunciation ?? this.pronunciation,
      highestRelevantTranslation: highestRelevantTranslation ?? this.highestRelevantTranslation,
      transcription: transcription ?? this.transcription,
      otherTranslations: otherTranslations ?? this.otherTranslations,
      definitions: definitions ?? this.definitions,
      definitionsSynonyms: definitionsSynonyms ?? this.definitionsSynonyms,
      examples: examples ?? this.examples,
      autoSpellingFix: autoSpellingFix ?? this.autoSpellingFix,
      strangeWord: strangeWord ?? this.strangeWord,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUpdated: imageUpdated ?? this.imageUpdated,
      images: images ?? this.images,
      imageSearchWord: imageSearchWord ?? this.imageSearchWord,
      translateLoading: translateLoading ?? this.translateLoading,
      imageLoading: imageLoading ?? this.imageLoading,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      saveLoading: saveLoading ?? this.saveLoading,
      savedTranslation: savedTranslation ?? this.savedTranslation,
      updateLoading: updateLoading ?? this.updateLoading,
      updatedTranslation: updatedTranslation ?? this.updatedTranslation,
      raw: raw ?? this.raw,
      remote: remote ?? this.remote,
      version: version ?? this.version,
      error: error != null ? error.value : this.error,
    );
  }

  // factory TranslationViewState.initial(SharedPreferences prefs) {
  //   final bool pronunciationAutoPlay = prefs.getBool('pronunciationAutoPlay') ?? true;
  //   final bool darkMode = prefs.getBool('darkMode') ?? false;
  //   final bool? autoDarkMode = prefs.getBool('autoDarkMode');
  //   final int? backupTime = prefs.getInt('backupTime');
  //   final int? backupSize = prefs.getInt('backupSize');
  //
  //   return TranslationViewState(
  //     pronunciationAutoPlay: pronunciationAutoPlay,
  //     darkMode: darkMode,
  //     autoDarkMode: autoDarkMode != null ? autoDarkMode : true,
  //     backupLoading: false,
  //     backupError: false,
  //     backupTime: backupTime,
  //     backupSize: backupSize,
  //   );
  // }

  factory TranslationViewState.fromJson(Map<String, dynamic> json) => _$TranslationViewStateFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationViewStateToJson(this);

  @override
  List<Object?> get props => [
    id,
    translateLoading,
    imageLoading,
    saveLoading,
    updateLoading,
    // pronunciationAutoPlay,
    // darkMode,
    // autoDarkMode,
    // backupLoading,
    // backupError,
    // backupTime,
    // backupSize,
    // backupPreloadSize,
  ];
}