import 'dart:convert';
import 'dart:typed_data';

Uint8List getBytesFrom64String(String source) {
  final RegExp base64Reg = RegExp(r'data:[^,]+,');
  return base64Decode(source.replaceFirst(base64Reg, ''));
}
