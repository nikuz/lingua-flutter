import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import 'package:lingua_flutter/utils/api.dart';
import '../model/item.dart';

abstract class TranslationsState extends Equatable {
  const TranslationsState();

  @override
  List<Object> get props => [];

  List<TranslationsItem> get translations => [];
  int get from => 0;
  int get to => 20;
  int get totalAmount => 0;
}

class TranslationsUninitialized extends TranslationsState {}

class TranslationsError extends TranslationsState {
  final ApiException error;

  TranslationsError([this.error]) : assert(error is ApiException);

  @override
  List<Object> get props => [error];

  @override
  String toString() => error.toString();
}

class TranslationsRequestLoading extends TranslationsState {
  final List<TranslationsItem> translations;

  const TranslationsRequestLoading(this.translations) : assert(translations != null);
}

class TranslationsRequestMoreLoading extends TranslationsState {
  final int totalAmount;
  final List<TranslationsItem> translations;

  const TranslationsRequestMoreLoading(this.totalAmount, this.translations)
      : assert(totalAmount != null, translations != null);
}

class TranslationsSearchLoading extends TranslationsState {}

class TranslationsLoaded extends TranslationsState {
  final int from;
  final int to;
  final int totalAmount;
  final List<TranslationsItem> translations;
  final String search;

  const TranslationsLoaded({
    @required this.from,
    @required this.to,
    @required this.totalAmount,
    @required this.translations,
    this.search,
  }) : assert(from != null && to != null && totalAmount != null && translations != null);

  TranslationsLoaded copyWith({
    int from,
    int to,
    int totalAmount,
    List<TranslationsItem> translations,
    TranslationsItem updatedItem,
  }) {
    List<TranslationsItem> newTranslations = translations ?? this.translations;

    if (updatedItem != null) {
      int updatedItemIndex = newTranslations.indexWhere((item) => item.id == updatedItem.id);
      if (updatedItemIndex != -1) {
        newTranslations = new List<TranslationsItem>.from(newTranslations);
        newTranslations[updatedItemIndex] = updatedItem;
      }
    }

    return TranslationsLoaded(
      from: from ?? this.from,
      to: from ?? this.to,
      totalAmount: from ?? this.totalAmount,
      translations: newTranslations,
    );
  }

  @override
  List<Object> get props => [from, to, totalAmount, translations, search];

  @override
  String toString() => 'Translations list length: ${translations.length}';
}
