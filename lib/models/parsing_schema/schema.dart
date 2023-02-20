import 'package:json_annotation/json_annotation.dart';
import './cookie_consent.dart';
import './quick_translation.dart';
import './translation_schema.dart';
import './pronunciation_schema.dart';
import './images_schema.dart';

export './cookie_consent.dart';
export './quick_translation.dart';
export './translation_schema.dart';
export './pronunciation_schema.dart';
export './images_schema.dart';
export './schema_item.dart';

part 'schema.g.dart';

@JsonSerializable(explicitToJson: true)
class ParsingSchema {
  final CookieConsentSchema cookieConsent;
  final QuickTranslationSchema quickTranslation;
  final TranslationSchema translation;
  final PronunciationSchema pronunciation;
  final ImagesSchema images;

  const ParsingSchema({
    required this.cookieConsent,
    required this.quickTranslation,
    required this.translation,
    required this.pronunciation,
    required this.images,
  });

  factory ParsingSchema.fromJson(Map<String, dynamic> json) => _$ParsingSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$ParsingSchemaToJson(this);
}