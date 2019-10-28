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

class TranslationsLoaded extends TranslationsState {
  final int from;
  final int to;
  final int totalAmount;
  final List<TranslationsItem> translations;

  const TranslationsLoaded({
    @required this.from,
    @required this.to,
    @required this.totalAmount,
    @required this.translations,
  }) : assert(from != null && to != null && totalAmount != null && translations != null);

  TranslationsLoaded copyWith({
    int from,
    int to,
    int totalAmount,
    List<TranslationsItem> translations,
  }) {
    return TranslationsLoaded(
      translations: translations ?? this.translations,
      from: from ?? this.from,
      to: from ?? this.to,
      totalAmount: from ?? this.totalAmount,
    );
  }

  @override
  List<Object> get props => [translations, from, to, totalAmount];

  @override
  String toString() => 'Translations list length: ${translations.length}';
}
