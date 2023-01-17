import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:lingua_flutter/models/parsing_schema/stored_schema.dart';
import 'package:lingua_flutter/utils/files.dart';

Future<String?> savePronunciationFile({
  required String fileId,
  required ParsingSchema schema,
  String? pronunciation,
}) async {
  String? filePath;

  if (pronunciation != null) {
    String dir = await getDocumentsPath();
    final RegExp pronunciationReg = RegExp('${schema.pronunciation.fields.base64Prefix}(.+)');
    RegExpMatch? pronunciationParts;
    pronunciationParts = pronunciationReg.firstMatch(pronunciation);
    String? pronunciationValue = pronunciationParts?.group(1);

    if (pronunciationParts != null && pronunciationValue != null) {
      Uint8List pronunciationBytes = const Base64Decoder().convert(pronunciationValue);
      filePath = '/pronunciations/$fileId.mp3';

      File pronunciationFile = File('$dir/$filePath');
      pronunciationFile = await pronunciationFile.create(recursive: true);
      await pronunciationFile.writeAsBytes(pronunciationBytes);
    }
  }

  return filePath;
}