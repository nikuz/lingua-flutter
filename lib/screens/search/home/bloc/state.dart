import 'package:equatable/equatable.dart';

import 'package:lingua_flutter/providers/api.dart';
import 'package:lingua_flutter/providers/db.dart';
import '../model/item.dart';

abstract class TranslationsState extends Equatable {
  const TranslationsState();

  @override
  List<Object> get props => [];

  List<TranslationsItem> get translations => [];
  int? get from => 0;
  int? get to => 20;
  int? get totalAmount => 0;
}

class TranslationsUninitialized extends TranslationsState {}

class TranslationsError extends TranslationsState {
  final error;

  TranslationsError([this.error]) : assert(error is ApiException || error is DBException);

  @override
  List<Object> get props => [error];

  @override
  String toString() => error.toString();
}

class TranslationsRequestLoading extends TranslationsState {
  final List<TranslationsItem> translations;
  final int? totalAmount;

  const TranslationsRequestLoading(
    this.translations,
    this.totalAmount,
  );
}

class TranslationsRequestMoreLoading extends TranslationsState {
  final int totalAmount;
  final List<TranslationsItem> translations;

  const TranslationsRequestMoreLoading(this.totalAmount, this.translations);
}

class TranslationsSearchLoading extends TranslationsState {}

class TranslationsLoaded extends TranslationsState {
  final int from;
  final int to;
  final int totalAmount;
  final List<TranslationsItem> translations;
  final String? search;

  const TranslationsLoaded({
    required this.from,
    required this.to,
    required this.totalAmount,
    required this.translations,
    this.search,
  });

  TranslationsLoaded copyWith({
    int? from,
    int? to,
    int? totalAmount,
    List<TranslationsItem>? translations,
    TranslationsItem? updatedItem,
    int? removedItemId,
  }) {
    int total = from ?? this.totalAmount;
    int to = from ?? this.to;
    List<TranslationsItem> newTranslations = translations ?? this.translations;

    if (updatedItem != null) {
      int updatedItemIndex = newTranslations.indexWhere((item) => item.id == updatedItem.id);
      if (updatedItemIndex != -1) {
        newTranslations = new List<TranslationsItem>.from(newTranslations);
        newTranslations[updatedItemIndex] = updatedItem;
      }
    }

    if (removedItemId != null) {
      int removedItemIndex = newTranslations.indexWhere((item) => item.id == removedItemId);
      if (removedItemIndex != -1) {
        newTranslations = new List<TranslationsItem>.from(newTranslations);
        newTranslations.removeAt(removedItemIndex);
      }
      to--;
      total--;
    }

    return TranslationsLoaded(
      from: from ?? this.from,
      to: to,
      totalAmount: total,
      translations: newTranslations,
      search: this.search,
    );
  }

  @override
  List<Object> get props => [from, to, totalAmount, translations, search ?? ''];

  @override
  String toString() => 'Translations list length: ${translations.length}';
}
