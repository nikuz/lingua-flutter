import 'package:equatable/equatable.dart';

abstract class TranslationsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class TranslationsRequest extends TranslationsEvent {}

class TranslationsRequestMore extends TranslationsEvent {}

class TranslationsSearch extends TranslationsEvent {
  final String text;

  TranslationsSearch(this.text);
}

class TranslationsUpdateItem extends TranslationsEvent {
  final int? id;
  final String? word;
  final String? translation;
  final String? pronunciation;
  final String? image;
  final String? imageUrl;
  final String? createdAt;
  final String updatedAt;

  TranslationsUpdateItem({
    required this.id,
    required this.word,
    required this.translation,
    required this.pronunciation,
    required this.image,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}

class TranslationsItemRemove extends TranslationsEvent {
  final int id;

  TranslationsItemRemove(this.id) : assert(id != null);
}
