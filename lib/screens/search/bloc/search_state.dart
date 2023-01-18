import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';

import '../search_constants.dart';
part 'search_state.g.dart';

@JsonSerializable()
class SearchState extends Equatable {
  final int from;
  final int to;
  final int totalAmount;
  final List<TranslationContainer> translations;
  final String? searchText;
  final TranslationContainer? quickTranslation;
  final CustomError? quickTranslationError;
  final bool quickTranslationLoading;
  final bool loading;
  final CustomError? error;

  const SearchState({
    this.from = 0,
    this.to = SearchConstants.itemsPerPage,
    this.totalAmount = 0,
    this.translations = const [],
    this.searchText,
    this.quickTranslation,
    this.quickTranslationError,
    this.quickTranslationLoading = false,
    this.loading = true,
    this.error,
  });

  SearchState copyWith({
    int? from,
    int? to,
    int? totalAmount,
    List<TranslationContainer>? translations,
    Wrapped<String?>? searchText,
    Wrapped<TranslationContainer?>? quickTranslation,
    Wrapped<CustomError?>? quickTranslationError,
    bool? quickTranslationLoading,
    bool? loading,
    Wrapped<CustomError?>? error,
  }) {
    return SearchState(
      from: from ?? this.from,
      to: to ?? this.to,
      totalAmount: totalAmount ?? this.totalAmount,
      translations: translations ?? this.translations,
      searchText: searchText != null ? searchText.value : this.searchText,
      quickTranslation: quickTranslation != null ? quickTranslation.value : this.quickTranslation,
      quickTranslationError: quickTranslationError != null ? quickTranslationError.value : this.quickTranslationError,
      quickTranslationLoading: quickTranslationLoading ?? this.quickTranslationLoading,
      loading: loading ?? this.loading,
      error: error != null ? error.value : this.error,
    );
  }

  factory SearchState.fromJson(Map<String, dynamic> json) => _$SearchStateFromJson(json);
  Map<String, dynamic> toJson() => _$SearchStateToJson(this);

  @override
  List<Object?> get props => [
    from,
    to,
    totalAmount,
    translations,
    searchText,
    quickTranslation,
    quickTranslationError,
    quickTranslationLoading,
    loading,
    error,
  ];
}