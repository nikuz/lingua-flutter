import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

const appName = 'Wisual';
const version = '1.0.1';
const minCurrentParsingSchema = 3;
const privacyEmail = 'wisual.app@gmail.com';
const playMarketUrl = 'https://google.com';
const appStoreUrl = 'https://apple.com';
const wordsAmountRateThreshold = 100; // how many words user should add to see "rate us" prompt
const purchaseProductId = 'full_access';
const wordsAmountPurchaseThreshold = 500; // how many words user should add to see "purchase" prompt

String getApiUrl() {
  if (kDebugMode) {
    String host = 'localhost';
    if (Platform.isAndroid) {
      // host = '10.0.2.2'; // strangely doesn't work
      host = '192.168.1.76';
    }
    return 'http://$host:8080';
  }
  return 'https://wisual.app';
}