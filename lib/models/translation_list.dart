import 'package:json_annotation/json_annotation.dart';
import './translation.dart';

part 'translation_list.g.dart';

@JsonSerializable(explicitToJson: true)
class TranslationList {
  final int from;
  final int to;
  final int totalAmount;
  final List<Translation> translations;

  const TranslationList({
    required this.from,
    required this.to,
    required this.totalAmount,
    required this.translations,
  });

  factory TranslationList.fromJson(Map<String, dynamic> json) => _$TranslationListFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationListToJson(this);
}
