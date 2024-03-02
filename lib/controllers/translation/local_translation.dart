import 'package:lingua_flutter/controllers/parsing_schema/parsing_schema.dart'
    as parsing_schema_controller;
import 'package:lingua_flutter/controllers/dictionary/dictionary.dart'
    as dictionary_controller;
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/models/translation_container/translation_container.dart';
import 'package:lingua_flutter/models/language/language.dart';
import 'package:lingua_flutter/utils/string.dart';

Future<TranslationContainer?> localTranslate({
  required String word,
  required Language translateFrom,
  required Language translateTo,
}) async {
  final encodedWord = removeQuotesFromString(removeSlashFromString(word));

  final existingTranslation = await dictionary_controller.get(
    encodedWord,
    translateFrom.id,
    translateTo.id,
  );
  if (existingTranslation != null) {
    final schemaVersion = existingTranslation.schemaVersion;
    StoredParsingSchema? storedParsingSchema;
    if (schemaVersion != null) {
      storedParsingSchema = await parsing_schema_controller.get(schemaVersion);
    }

    if (existingTranslation.raw != null && storedParsingSchema != null) {
      try {
        return TranslationContainer.fromRaw(
          id: existingTranslation.id,
          cloudId: existingTranslation.cloudId,
          word: word,
          translation: existingTranslation.translation,
          pronunciationFrom: existingTranslation.pronunciationFrom,
          pronunciationTo: existingTranslation.pronunciationTo,
          image: existingTranslation.image,
          raw: existingTranslation.raw!,
          schema: storedParsingSchema.schema,
          schemaVersion: storedParsingSchema.version,
          translateFrom: existingTranslation.translateFrom,
          translateTo: existingTranslation.translateTo,
          createdAt: existingTranslation.createdAt,
          updatedAt: existingTranslation.updatedAt,
        );
      } catch (e) {
        // don't throw error here, but instead allow script to proceed into cloud translation phase if local translation failed
      }
    }
  }

  return null;
}
