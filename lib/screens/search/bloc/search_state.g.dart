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
              ?.map((e) =>
                  TranslationContainer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      searchText: json['searchText'] as String?,
      quickTranslation: json['quickTranslation'] == null
          ? null
          : QuickTranslation.fromJson(
              json['quickTranslation'] as Map<String, dynamic>),
      quickTranslationWithAutoLanguage:
          json['quickTranslationWithAutoLanguage'] == null
              ? null
              : QuickTranslation.fromJson(
                  json['quickTranslationWithAutoLanguage']
                      as Map<String, dynamic>),
      quickTranslationError: json['quickTranslationError'] == null
          ? null
          : CustomError.fromJson(
              json['quickTranslationError'] as Map<String, dynamic>),
      quickTranslationLoading:
          json['quickTranslationLoading'] as bool? ?? false,
      loading: json['loading'] as bool? ?? true,
      error: json['error'] == null
          ? null
          : CustomError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchStateToJson(SearchState instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'totalAmount': instance.totalAmount,
      'translations': instance.translations,
      'searchText': instance.searchText,
      'quickTranslation': instance.quickTranslation,
      'quickTranslationWithAutoLanguage':
          instance.quickTranslationWithAutoLanguage,
      'quickTranslationError': instance.quickTranslationError,
      'quickTranslationLoading': instance.quickTranslationLoading,
      'loading': instance.loading,
      'error': instance.error,
    };
