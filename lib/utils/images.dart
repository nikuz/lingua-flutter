import 'dart:convert';
import 'dart:typed_data';

Uint8List getImageBytesFrom64String(String imageSource) {
  final RegExp base64Reg = RegExp(r'data:image[^,]+,');
  return base64Decode(imageSource.replaceFirst(base64Reg, ''));
}
