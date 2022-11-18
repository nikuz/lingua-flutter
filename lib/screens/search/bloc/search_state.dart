import 'package:equatable/equatable.dart';
import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/providers/db.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lingua_flutter/utils/types.dart';
import 'package:lingua_flutter/models/translation_model.dart';

import '../search_constants.dart';
part 'search_state.g.dart';

@JsonSerializable()
class SearchState extends Equatable {
  final int from;
  final int to;
  final int totalAmount;
  final List<Translation> translations;
  final String? searchText;
  final bool loading;
  final error;

  const SearchState({
    this.from = 0,
    this.to = SearchConstants.itemsPerPage,
    this.totalAmount = 0,
    this.translations = const [],
    this.searchText,
    this.loading = false,
    this.error,
  });

  SearchState copyWith({
    int? from,
    int? to,
    int? totalAmount,
    List<Translation>? translations,
    String? searchText,
    bool? loading,
    Wrapped? error,
  }) {
    return SearchState(
      from: from ?? this.from,
      to: to ?? this.to,
      totalAmount: totalAmount ?? this.totalAmount,
      translations: translations ?? this.translations,
      searchText: searchText ?? this.searchText,
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
    loading,
    error,
  ];
}