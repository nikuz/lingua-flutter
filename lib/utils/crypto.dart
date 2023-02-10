import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:lingua_flutter/models/error/error.dart';
import 'package:lingua_flutter/app_config.secret.dart' as secret_config;

const _algorithm = 'AES';
const _mode = 'CBC';
const _padding = 'PKCS7';
const _numKeyBytes = 32;
final _secret = _normalizeSecret(secret_config.cryptoSecret);
final _random = Random.secure();
final _iv = Uint8List.fromList(List<int>.generate(16, (i) => _random.nextInt(256)));

String _normalizeSecret(String secret) {
  final secretBytes = Uint8List.fromList(secret.codeUnits);
  final secretBase64 = base64Encode(SHA256Digest().process(secretBytes));

  return secretBase64.substring(0, _numKeyBytes);
}

String encrypt(String text) {
  if (text == '') {
    return text;
  }

  final secretBytes = Uint8List.fromList(_secret.codeUnits);
  final key = ParametersWithIV(KeyParameter(secretBytes), _iv);
  final textBytes = Uint8List.fromList(text.codeUnits);
  final cipher = PaddedBlockCipher('$_algorithm/$_mode/$_padding')..init(true, PaddedBlockCipherParameters(key, null));
  final cipherText = cipher.process(textBytes);

  return '${hex.encode(_iv)}.${hex.encode(cipherText)}';
}

String decrypt(String text) {
  List<String> parts = text.split('.');
  if (parts.length != 2) {
    throw const CustomError(
      code: 0,
      message: 'Can\'t decrypt text. Text must contain dot splitter.',
    );
  }

  final iv = Uint8List.fromList(hex.decode(parts[0]));
  final secretBytes = Uint8List.fromList(_secret.codeUnits);
  final key = ParametersWithIV(KeyParameter(secretBytes), iv);
  final textBytes = Uint8List.fromList(hex.decode(parts[1]));
  final cipher = PaddedBlockCipher('$_algorithm/$_mode/$_padding')..init(false, PaddedBlockCipherParameters(key, null));

  return String.fromCharCodes(cipher.process(textBytes));
}

String hash(String text) {
  final secretBytes = Uint8List.fromList(secret_config.cryptoSecret.codeUnits);
  final textBytes = Uint8List.fromList(text.codeUnits);
  final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(secretBytes));

  return hex.encode(hmac.process(textBytes));
}