import 'package:equatable/equatable.dart';

import './item.dart';

const LIST_PAGE_SIZE = 20;

class Translations extends Equatable {
  final int from;
  final int to;
  final int totalAmount;
  final List<TranslationsItem> translations;

  Translations({
    this.from,
    this.to,
    this.totalAmount,
    this.translations,
  });

  @override
  List<Object> get props => [
    from,
    to,
    totalAmount,
    translations,
  ];

  @override
  String toString() => '{ from: $from, to: $to, totalAmount: $totalAmount }';
}
