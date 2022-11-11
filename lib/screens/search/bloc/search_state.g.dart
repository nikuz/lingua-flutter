// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchState _$SearchStateFromJson(Map<String, dynamic> json) => SearchState(
      from: json['from'] as int? ?? 0,
      to: json['to'] as int? ?? SearchConstants.itemsPerPage,
      totalAmount: json['totalAmount'] as int? ?? 0,
      translations: (json['translations'] as List<dynamic>?)
              ?.map((e) => Translation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      searchText: json['searchText'] as String?,
      loading: json['loading'] as bool? ?? false,
      error: json['error'],
    );

Map<String, dynamic> _$SearchStateToJson(SearchState instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'totalAmount': instance.totalAmount,
      'translations': instance.translations,
      'searchText': instance.searchText,
      'loading': instance.loading,
      'error': instance.error,
    };
